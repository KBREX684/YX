# P1 阶段出口走查记录

版本：v0.1.1
关联实施计划：[`../00-implementation-plan.md`](../00-implementation-plan.md) v2.5.1
关联工程任务书：[`../00-engineering-tasks.md`](../00-engineering-tasks.md) v1.5.4
创建日期：2026-05-14
最后更新：2026-05-14
状态：通过

---

## 一、结论

P1（地图与玩家原型）出口门禁通过，可以进入 P2-1 RuleEngine 与怪物异常规则施工。

本阶段已完成无怪物状态下的基础可玩链路：玩家能在破败校园副本灰盒中移动、奔跑、蹲伏、开关手电、触发交互、拾取占位物、阅读线索占位和进入躲藏点；副本包含入口区、主走廊、4 个候选房间、仪式房、出口区和地图变化事件占位。

---

## 二、设计

P1 的设计边界保持收敛：只验证"人在图中"和基础探索动词，不接入怪物追杀、死亡复活、正式线索系统、正式搜刮系统或最终美术。

- 玩家基础动词由 `PlayerController` + Input Map action 驱动，不硬编码物理按键。
- 地图采用手工灰盒 + 2.5D Live 占位标注，不引入程序化大地图或最终 TileMap 方案。
- 交互物统一返回 payload，由玩家控制器消费，避免对象反向直接改写玩家状态。
- Dialogic 2 在 P1 只保留 `dialogic_timeline_id` 占位，不启用运行时 Autoload。

---

## 三、搭建

| 门禁项 | 结果 | 证据 |
|---|---|---|
| 微切片 Input Map action 全部存在 | 通过 | `project.godot` 定义 `move_left/right/up/down`、`run`、`crouch`、`flashlight`、`interact`、`hide`、`pause`；`test_player_controller.gd` 覆盖 |
| 玩家能完成行走、奔跑、蹲伏、开关手电、互动和躲藏 | 通过 | `scenes/player/player.tscn` + `scripts/player/player.gd`；`test_player_controller.gd`、`test_interactables_stub.gd` 覆盖 |
| 微切片场景包含走廊、2 房间、1 躲藏点、1 交互占位物 | 通过 | `scenes/dungeon/micro_school_blockout.tscn`；`test_dungeon_blockout.gd` 覆盖 |
| 至少 1 次地图变化事件可触发且不阻断逃离占位路径 | 通过 | `scripts/dungeon/map_change_event.gd`；`test_micro_map_change_event_is_triggerable_and_keeps_escape_path` 覆盖 |
| 至少 1 条噪声事件经 EventBus 发出并带稳定 action id | 通过 | `EventBus.noise_emitted(level, position, source_action_id)`；`test_player_movement_state_emits_noise_with_action_id` 覆盖 |
| VS §1 第 1 项：完整副本基础动作 | 通过 | `abandoned_school.tscn` 内 5 个交互实例 + GUT 覆盖 |
| VS §1 第 3 项：手电开关、电量消耗、低电量反馈 | 通过 | `data/items/flashlight.tres` + `test_player_flashlight_consumes_battery_and_dims_when_low` |
| VS §3：副本地图结构、变化事件、三路径不阻断、候选房间池 | 通过 | `abandoned_school.tscn`、`LevelResource`、`RoomPool`；`test_dungeon_blockout.gd` 覆盖 |

---

## 四、审计修复

- `player.gd` 新增交互消费后曾超过 P1-1 的 200 行约束，已收束到 193 行。
- 任一交互物脚本均低于 80 行：`door.gd` 23 行、`pickup.gd` 18 行、`note.gd` 14 行、`hiding_spot.gd` 11 行、`interactable.gd` 21 行。
- 派生交互脚本使用显式脚本路径继承 `res://scripts/objects/interactable.gd`，规避 headless 环境中新 `class_name` 导入缓存未就绪造成的解析失败。
- GoPeak 编辑器桥接当前因 `127.0.0.1:6506` 被占用不可连接；已使用 GoPeak `resource_dependencies` 完成资源依赖审计，未发现循环依赖。
- `AGENTS.md` 未被暂存或提交。

---

## 五、验收

| 命令 / 工具 | 结果 |
|---|---|
| `godot --headless --path . -s res://addons/gut/gut_cmdln.gd -gconfig=res://tests/.gutconfig.json -gexit` | 通过，17/17 tests，107 asserts |
| `godot --headless --path . --script res://tools/validate_schemas.gd` | 通过；7 个资源检查，P1 新增未注册资源按 P8 schema hardening 前口径保持 SKIP |
| `godot --headless --path . res://scenes/dungeon/abandoned_school.tscn --quit` | 通过 |
| `godot --headless --path . res://scenes/objects/door.tscn --quit` | 通过 |
| `godot --headless --path . res://scenes/objects/pickup.tscn --quit` | 通过 |
| `godot --headless --path . res://scenes/objects/note.tscn --quit` | 通过 |
| `godot --headless --path . res://scenes/objects/hiding_spot.tscn --quit` | 通过 |
| GoPeak `resource_dependencies` | `abandoned_school.tscn` 与交互物场景无循环依赖 |
| `git diff --check` | 通过；仅文档 CRLF/LF 提示，无 whitespace error |

---

## 六、延后项

以下项不阻塞 P1，按实施计划进入后续阶段：

- VS §1 第 2 项（不同玩家行为导致怪物判断不同）已完成噪声接口，最终可观察验收推迟至 P2-2。
- VS §1 第 4 项（死亡后从基地复活、资源损失）推迟至 P3-4。
- Dialogic 2 正式线索/对话接入推迟至 P3-1，P1 只保留 timeline 占位字段。
- 正式搜刮系统与持久背包推迟至 P4-1，P1 临时背包只验证拾取动词。
- `FlashlightResource`、`LevelResource`、`ManifestResource` 的强 schema 注册推迟至 P8-2。
- GoPeak bridge 端口占用需在需要编辑器桥接、运行态截图或输入注入前处理；P1 阶段 CLI 与资源依赖审计已足够。

---

## 版本记录

### v0.1.1 - 2026-05-14

- 同步关联实施计划与工程任务书版本至 P1 出口记录完成后的版本。

### v0.1.0 - 2026-05-14

- 建立 P1 阶段出口走查记录。
- 记录设计、搭建、审计修复、验收和延后项。
