# P2 阶段出口走查记录

版本：v0.1.0
关联实施计划：[`../00-implementation-plan.md`](../00-implementation-plan.md) v2.5.6
关联工程任务书：[`../00-engineering-tasks.md`](../00-engineering-tasks.md) v1.5.9
创建日期：2026-05-14
最后更新：2026-05-14
状态：通过

---

## 一、结论

P2（怪物系统与感知压力）出口门禁通过，可进入 P3-1 线索系统与规则推理施工。

本阶段已完成：RuleEngine 数据驱动规则评估、大只 AI 骨架与阶段变化、压力反馈系统、首次入场现形、第二现形规则、线索规则占位池，以及 P3 线索系统所需的稳定 `clue_unlock_id` 锚点。

---

## 二、设计

P2 的设计边界保持收敛：只证明“大只能被规则驱动、能给玩家可学习的压力反馈”，不提前实现完整线索阅读、击杀/收容执行、死亡复活或结算。

- 大只不读取具体 `rule_da_zhi_*` 字符串，只消费 `RuleEngine` 注入的 `rule_effect`。
- 压力反馈通过 `EventBus.pressure_changed(level)` 输入到普通场景节点 `PressureLevel`，没有扩张 Autoload 白名单。
- 现形条件至少两类：首次进入主走廊、手电长时间凝视空走廊。
- 线索规则占位只登记 `clue_unlock_id` 和规则元数据，不绑定 Dialogic timeline 或笔记正文。

---

## 三、搭建

| 门禁项 | 结果 | 证据 |
|---|---|---|
| VS §1 第 2 项：奔跑等行为产生不同怪物判断结果 | 通过 | `rule_da_zhi_corridor_run` + `test_noise_rule_changes_da_zhi_phase_but_walk_does_not`；奔跑进入 `search`，行走不触发 |
| VS §2 第 1-3 项：声音/心跳/手电/环境反馈可区分远近 | 通过 | `PressureLevel` 快照包含 `heartbeat_intensity`、`flashlight_flicker_hz`、`ambience_volume_db`；`test_pressure_level_maps_far_and_near_feedback` 覆盖 |
| VS §2 第 4 项：首次进入副本至少一次弱光现形 | 通过 | `FirstEntryManifestTrigger` 调用 `show_apparition(2.5)`；`test_abandoned_school_wires_first_entry_pressure_feedback` 覆盖 |
| VS §2 第 5 项：低理智线索干扰最低链路 | 通过 | `PressureLevel` 输出 `clue_reliability` 与 `screen_fx_intensity`；正式 Dialogic 文本干扰由 P3-1 接管 |
| VS §4 第 1 项：大只通常不可见，至少两种特定条件现形 | 通过 | `rule_da_zhi_first_manifestation`、`rule_da_zhi_flashlight_stare_manifestation`；`manifestation_count >= 2` 测试覆盖 |
| VS §4 第 2 项：接近可通过间接反馈判断 | 通过 | 大只阶段变化发出 `pressure_changed`，HUD/心跳/AudioBus 响应；`test_da_zhi_phase_and_manifestation_emit_pressure` 覆盖 |
| VS §4 第 3 项：AI 阶段流程明确且不随机传送 | 通过 | `DaZhiAI` 使用 LimboHSM phase + `NavigationAgent2D`；脚本测试禁止 `rule_da_zhi_` 硬编码和随机逻辑 |
| RuleEngine GUT 100% | 通过 | `test_rule_engine.gd` 9/9 通过 |

---

## 四、审计修复

- P2-5 走查发现“大只至少两种特定条件现形”不足；已补 `rule_da_zhi_flashlight_stare_manifestation.tres`，并写入 `data/monsters/da_zhi.tres`。
- `PressureLevel`、`DaZhiAI`、HUD、心跳播放器和首次入场触发器均低于单文件 400 行红线。
- Autoload 白名单保持 5 项：`GameState`、`EventBus`、`SaveSystem`、`AudioManager`、`Config`。
- GoPeak 编辑器桥接当前因 `127.0.0.1:6506` 被占用不可连接；已使用 GoPeak `resource_dependencies` 完成资源依赖审计，未发现循环依赖。
- `AGENTS.md` 未被暂存或提交。

---

## 五、验收

| 命令 / 工具 | 结果 |
|---|---|
| `godot --headless --path . -s res://addons/gut/gut_cmdln.gd -gconfig=res://tests/.gutconfig.json -gexit` | 通过：42/42 tests，236 asserts |
| `godot --headless --path . --script res://tools/validate_schemas.gd` | 通过：17 个资源检查；未注册资源按 P8 schema hardening 前口径保持 SKIP |
| `godot --headless --path . --quit-after 1 res://scenes/dungeon/abandoned_school.tscn` | 通过 |
| `godot --headless --path . --quit-after 1 res://scenes/monster/da_zhi.tscn` | 通过 |
| `godot --headless --path . --quit-after 1 res://scenes/ui/hud/pressure_hud.tscn` | 通过 |
| `godot --headless --path . --quit-after 1 res://scenes/audio/heartbeat_player.tscn` | 通过 |
| GoPeak `resource_dependencies` | 关键 P2 场景、规则、AudioBus 和 profile 无循环依赖 |
| `git diff --check` | 通过 |

---

## 六、延后项

以下内容不阻塞 P2，按实施计划进入后续阶段：

- P3-1：正式线索对象、Dialogic timeline、`ClueBook` 与 `GameState.known_clue_ids`。
- P3-2：击杀弱点的完整执行链与三步收容仪式。
- P3-4：死亡复活、资源损失和 `learnable_hint` 显示。
- P4：正式搜刮、素材与原形养成数据。
- P5：基地内档案页、原形携带和完整循环联调。
- P8-2：`AudioBusLayout`、`FlashlightResource`、`LevelResource`、`ManifestResource` 的强 schema 注册。

---

## 版本记录

### v0.1.0 - 2026-05-14

- 建立 P2 阶段出口走查记录。
- 记录设计、搭建、审计修复、验收结果和后续延后项。
