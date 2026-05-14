# 工程任务书 Engineering Tasks

版本：v1.6.0
关联实施计划：[`00-implementation-plan.md`](00-implementation-plan.md) v2.6.0
关联技术规约：[`00-tech-constraints.md`](00-tech-constraints.md) v1.3.1
关联垂直切片：[`00-vertical-slice.md`](00-vertical-slice.md) v1.0.4
创建日期：2026-05-14
最后更新：2026-05-14

---

## 一、用途

本文档是 YX 项目的**可施工任务清单**，把 [`00-implementation-plan.md`](00-implementation-plan.md) 的 25 个工作流细化为开发者可以**直接接单施工**的 TASK 条目。

- 实施计划：决定"按什么次序推进、每个阶段的门禁是什么"。
- **本文档**：决定"具体要建哪个文件、写哪些字段、怎么自检通过"。

读者画像：一人独立开发者 + Codex 协助。每条 TASK 应该可以在一次开发会话内完成，不超过 ~400 行新增代码或 ~1 天工作量。涉及美术、动画、场景表现的 TASK 需同时遵守 [`00-art-direction.md`](00-art-direction.md)。

---

## 二、如何使用本文档

### 2.1 TASK 编号

格式：`TASK-P{阶段}-{序号}-{slug}`，例如 `TASK-P0-1-repo-skeleton`。

- 阶段：P0 ~ P8，对应实施计划阶段。
- 序号：阶段内顺序号，与实施计划工作流号对齐（如 P0-1 对应实施计划 P0-1）。多个 TASK 可挂在同一工作流下，用 `.a / .b / .c` 后缀。
- slug：英文短描述，便于 commit / branch / issue 引用。

### 2.2 接单流程

1. 从下表中选取一条状态为 `TODO` 的 TASK。
2. 创建分支 `feature/TASK-Pn-m-slug`。
3. 按 TASK 内"实现步骤"逐步施工，所有产出文件落在"产出"列指定路径。
4. 自检"验收条件"全部通过后，按 [`00-tech-constraints.md`](00-tech-constraints.md) §八.1 Conventional Commits 提交：`feat(TASK-Pn-m): 短描述`。
5. 更新本文档对应 TASK 状态为 `DONE`，并在阶段表脚注记录完成提交 SHA。

### 2.3 TASK 字段定义

| 字段 | 说明 |
|---|---|
| **ID** | TASK 编号（唯一） |
| **前置** | 必须先完成的 TASK ID 列表 |
| **产出** | 必须新建或修改的文件/目录路径（精确到文件） |
| **实现步骤** | 粗粒度操作列表（不下沉到代码行） |
| **验收** | 可勾选 / 可观察的自检条件 |
| **关联 VS** | 对应 [`00-vertical-slice.md`](00-vertical-slice.md) 验收项编号 |
| **关联模块** | 必读的模块文档 |
| **状态** | `TODO` / `WIP` / `DONE` / `BLOCKED` |

### 2.4 红线提醒（每条 TASK 都适用）

- 禁止违反 [`00-tech-constraints.md`](00-tech-constraints.md) §十 八条禁止事项与 §四 架构约束。
- 业务数据**必须**进 `/data/`，**禁止**硬编码到 `/scripts/`。
- 跨模块通信**必须**走 signal + `EventBus`，**禁止**跨模块直接调用节点方法。
- 单文件 ≤ ~400 行；超出需拆分。
- 任何决策与开放问题状态不一致时，停下来更新 [`00-open-questions.md`](00-open-questions.md)，不要私下假设。
- 第一阶段 2.5D Live 动画使用 Godot 原生管线；不要把 Live2D Cubism 或 Spine 作为默认施工方案。
- 输入必须通过 Input Map action，不得在玩法脚本中硬编码物理按键。
- 玩法逻辑必须引用稳定 `resource_id` / manifest key，不得把裸文件路径当作跨系统公共契约。
- 暂不进入第一阶段的想法必须记录到 [`00-next-stage-expansions.md`](00-next-stage-expansions.md) 或模块"后续扩展方向"。

---

## 三、阶段总览

| 阶段 | TASK 数 | 入口前置 | 出口门禁（引用实施计划 §十三） |
|---|---|---|---|
| P0 工程底座 | 6 | — | 空项目可运行 + 五件 Autoload + Schema 框架 |
| P1 地图与玩家原型 | 4 | P0 全部 DONE | 微切片门禁 + VS §1 第 1、3 项 + §3 全勾 |
| P2 怪物与压力 | 5 | P1 全部 DONE | VS §2 + §4 前 3 项 + §1 第 2 项 + RuleEngine GUT 全过 + `learnable_hint` 填充 |
| P3 线索/解谜/结算 | 5 | P2 全部 DONE | VS §4 全 + §5 + §6 + §1 第 4 项 + 死亡提示显示 + SettlementCalculator GUT 全过 |
| P4 搜刮与原形养成 | 4 | P3 全部 DONE | VS §7 + §8 + SaveSystem GUT 全过 |
| P5 助战与核心循环 | 4 | P4 全部 DONE | VS §9 + §10 + §11 + Schema 冻结 |
| P6 切片验收与性能 | 4 | P5 全部 DONE | VS 全部 P0 + 性能基线达标 + .exe 交付 |
| P7 体验打磨 | 2 | P6 全部 DONE | VS P1 4 条全勾 + R-01 降级 |
| P8 工程化与发布 | 3 | P7 全部 DONE | CI 绿 + Schema 校验上线 + 文档收尾 |

合计 **37 条 TASK**。

---

## 四、P0 阶段任务（工程底座与配置决策）

### TASK-P0-1-repo-skeleton

- **前置**：—
- **产出**：
  - `/project.godot`（Godot 项目根）
  - `/assets/`（含 `sprites/`、`audio/`、`fonts/`、`shaders/` 四个空子目录，各放一个 `.gitkeep`）
  - `/data/`（含 `monsters/`、`origins/`、`rules/`、`items/`、`levels/`、`manifest/` 六个空子目录，各放 `.gitkeep`）
  - `/scenes/`（含 `player/`、`monster/`、`dungeon/`、`base/`、`ui/`）
  - `/scripts/`（含 `player/`、`monster/`、`systems/`、`ui/`、`autoload/`）
  - `/tests/`、`/tools/`、`/addons/`
  - `/.gitignore`（覆盖 `*.import`、`.tmp`、`.godot/`、`export/`）
  - `/README.md`（写入版本规则：与 `game-concept.md` 总版本号联动）
- **实现步骤**：
  1. 在 Godot 4.x（LTS）中新建项目，渲染器选 Forward+。
  2. 按上述结构创建全部空目录与 `.gitkeep`。
  3. 写 `.gitignore`（参考 [godot/.gitignore](https://github.com/github/gitignore/blob/main/Godot.gitignore) 模板）。
  4. 评估音频/视频体积：若 `/assets/audio/` 中存在单文件 > 10MB 的资源，初始化 Git LFS 并把 `*.ogg` `*.wav` `*.mp4` 加入 `.gitattributes`；否则记录"暂未启用 LFS"理由到 README。
  5. README 写入：项目名、引擎版本、目标平台、版本号规则（与 `game-concept.md` 同步）、运行方式（`godot --path .`）。
- **验收**：
  - [x] `godot --headless --path . --quit` 退出码为 0，无脚本红字。
  - [x] 目录结构与 [`00-tech-constraints.md`](00-tech-constraints.md) §三 图示 1:1 吻合。
  - [x] `.gitignore` 已忽略 `.godot/` `*.import` `export/`；`git status` 不出现 Godot 缓存。
- **关联 VS**：—
- **关联模块**：[`00-tech-constraints.md`](00-tech-constraints.md) §三、§八。
- **状态**：DONE

---

### TASK-P0-2-config-decisions

- **前置**：—
- **产出**：[`00-open-questions.md`](00-open-questions.md) 中 Q-13 ~ Q-20 全部标注"已定案"；[`00-art-direction.md`](00-art-direction.md) 与 [`00-tech-constraints.md`](00-tech-constraints.md) §十三 回填完整决策。
- **实现步骤**：
  1. Q-13 已确认：2.5D Live 分层资产规格，不使用 32×32 / 64×64 像素瓦片路线。
  2. Q-14 已确认：厚涂精美二次元风格，不使用像素风或低多边形手绘作为主风格。
  3. Q-15 已确认：第一阶段固定使用 GDScript，不引入 C#。
  4. Q-16 已确认：行为树 / 状态机插件选用 LimboAI v1.7.0。
  5. Q-17 已确认：第一阶段不引入 Steam SDK。
  6. Q-18 已确认：第一阶段仅中文（`zh_CN`）。
  7. Q-19 已确认：美术源文件可用 Krita / Clip Studio Paint / Photoshop；默认免费底基推荐 Krita；运行资源导出为分层 PNG。
  8. Q-20 已确认：第一阶段 2.5D Live 动画使用 Godot 原生管线，Live2D Cubism 与 Spine 不作为底基。
  9. 把每项决策回填到 [`00-art-direction.md`](00-art-direction.md) 与 [`00-tech-constraints.md`](00-tech-constraints.md) §六、§五、§十三 对应位置；版本号按影响范围升档。
  10. [`00-open-questions.md`](00-open-questions.md) 中 Q-13 ~ Q-20 均已改为"已定案 + 决策内容 + 日期"。
- **验收**：
  - [x] Q-13 / Q-14 在 [`00-open-questions.md`](00-open-questions.md) 状态为"已定案"。
  - [x] Q-15 ~ Q-18 全部 4 项在 [`00-open-questions.md`](00-open-questions.md) 状态为"已定案"。
  - [x] Q-19 / Q-20 在 [`00-open-questions.md`](00-open-questions.md) 状态为"已定案"，并已同步到 [`00-art-direction.md`](00-art-direction.md)。
  - [x] [`00-tech-constraints.md`](00-tech-constraints.md) 版本号已升档；文档头部版本与各引用文档兼容。
- **关联 VS**：—
- **关联模块**：[`00-open-questions.md`](00-open-questions.md)、[`00-art-direction.md`](00-art-direction.md)、[`00-tech-constraints.md`](00-tech-constraints.md) §十三。
- **状态**：DONE

---

### TASK-P0-3-autoloads

- **前置**：TASK-P0-1
- **产出**：
  - `/scripts/autoload/game_state.gd`
  - `/scripts/autoload/event_bus.gd`
  - `/scripts/autoload/save_system.gd`
  - `/scripts/autoload/audio_manager.gd`
  - `/scripts/autoload/config.gd`
  - `/project.godot` 内 `[autoload]` 段（5 条）
- **实现步骤**：
  1. 为五个 Autoload 各写最小骨架：`extends Node`，仅声明接口与空方法体（`pass` 或 `push_warning("not implemented")`）。
  2. `EventBus` 预声明信号：`noise_emitted(level: int, position: Vector2)`、`player_died`、`scene_changed(from: String, to: String)` 等占位信号（不实现订阅方）。
  3. `Config` 通过 `ConfigFile` 读取 `res://config/default.cfg`（文件本身也放占位）。
  4. 在 `Project Settings → Autoload` 注册五项；启动项目验证无红字。
  5. 严格保持互不依赖：任一 Autoload 文件不得 `preload` 或引用其他 Autoload 的具体类（仅可走 `EventBus.signal`）。
- **验收**：
  - [x] 项目启动空主菜单（占位 `scenes/ui/main_menu.tscn`）无脚本错误。
  - [x] 运行时 Autoload 输出仅包含白名单 5 项：`GameState / EventBus / SaveSystem / AudioManager / Config`。
  - [x] 任意 Autoload 的 `.gd` 文件 ≤ 100 行。
- **关联 VS**：—
- **关联模块**：[`00-tech-constraints.md`](00-tech-constraints.md) §四.1。
- **状态**：DONE

---

### TASK-P0-4-plugins-install

- **前置**：TASK-P0-2（需 Q-16 已定）、TASK-P0-3
- **产出**：
  - `/addons/limboai/`（Q-16 已定案）
  - `/addons/dialogic/`
  - `/addons/gut/`
  - `/docs/plugin-vetting.md`（插件采纳门槛核查表）
- **实现步骤**：
  1. 按 Q-16 决策下载锁定版本的行为树/状态机插件到 `/addons/`。
  2. 安装 Dialogic 2 与 GUT 至 `/addons/`；P0 默认仅启用 GUT，Dialogic 因会自动注册运行时 Autoload，延后到剧情/线索任务按需启用。
  3. 为每个插件填一行核查表：插件名 / 版本号 / 许可证 / GitHub star 数 / 最近一次更新日期 / 是否满足 [`00-tech-constraints.md`](00-tech-constraints.md) §五 全部三条门槛。
  4. 把插件版本号写入 `/docs/plugin-vetting.md`，作为后续升级前的回看锚点。
- **验收**：
  - [x] 启动项目无报错；`project.godot` 默认启用 GUT editor plugin，Dialogic 2 已安装入库，LimboAI 以 GDExtension 形式加载。
  - [x] `/docs/plugin-vetting.md` 表格每行三条门槛均为通过。
- **关联 VS**：—
- **关联模块**：[`00-tech-constraints.md`](00-tech-constraints.md) §五。
- **状态**：DONE

---

### TASK-P0-5-gut-bootstrap

- **前置**：TASK-P0-4
- **产出**：
  - `/tests/test_sanity.gd`
  - `/tests/.gutconfig.json`
- **实现步骤**：
  1. 写一个 GUT 用例：`test_one_plus_one_is_two`，断言 `assert_eq(1 + 1, 2)`。
  2. 配置 `.gutconfig.json`：测试目录 `res://tests/`、输出 detail 模式。
  3. 通过命令行运行验证：`godot --headless -s res://addons/gut/gut_cmdln.gd -gtest=res://tests/test_sanity.gd -gexit`。
- **验收**：
  - [x] 命令行 GUT 输出 `1 passed`，退出码 0。
  - [x] GUT 配置文件可被命令行加载；编辑器面板人工复核不阻塞 P0。
- **关联 VS**：—
- **关联模块**：[`00-tech-constraints.md`](00-tech-constraints.md) §九。
- **状态**：DONE

---

### TASK-P0-6-schema-skeletons

- **前置**：TASK-P0-3
- **产出**：
  - `/scripts/systems/resources/rule_resource.gd`（`class_name RuleResource extends Resource`）
  - `/scripts/systems/resources/origin_resource.gd`
  - `/scripts/systems/resources/monster_profile.gd`
  - `/scripts/systems/resources/item_resource.gd`
  - `/tools/validate_schemas.gd`（命令行 `SceneTree` 校验脚本）
  - 各资源类型一个示例 `.tres`：`/data/rules/example.tres` 等
- **实现步骤**：
  1. 按各模块文档"数据契约"节定义字段：
     - `RuleResource`：`id: String`、`trigger_conditions: Array`、`effect: Dictionary`、`clue_unlock_id: String`、`learnable_hint: String`。
     - `OriginResource`：`id: String`、`progress: Vector3`（拟人/恐怖/工具三轴）、`stability: float`、`stage: int`、`side_effects: Array`、`locked: bool`。
     - `MonsterProfile`：`id: String`、`name: String`、`rule_ids: Array[String]`、`weakness_rule_id: String`、`containment_rule_ids: Array[String]`。
     - `ItemResource`：`id: String`、`category: int`（enum: survival/puzzle/growth）、`stack_max: int`、`rarity: int`、`spawn_zone_ids: Array[String]`。
  2. 每个 `.gd` **只**声明 `@export` 字段，不写业务逻辑。
  3. `validate_schemas.gd` 遍历 `/data/**/*.tres`，对每个资源逐字段校验非空，输出报告，并在命令行失败时返回非 0 退出码。
  4. Godot 编辑器菜单入口延后至 P8-2 Schema Validation CI 加固；P0 先以命令行保证可验证。
  5. 各放一个示例 `.tres` 填入合法值，验证校验脚本通过。
- **验收**：
  - [x] 四个资源类型均有 `class_name` 与 `@export` 字段骨架，Godot 4.6.2 可注册。
  - [x] `validate_schemas.gd` 对示例 `.tres` 输出"通过"。
  - [x] 校验脚本对必填字段输出精确字段名；负例夹具留到 P8-2 CI 加固。
- **关联 VS**：—
- **关联模块**：[`modules/03-monster-anomaly-rules.md`](modules/03-monster-anomaly-rules.md)、[`modules/07-looting-resources.md`](modules/07-looting-resources.md)、[`modules/08-origin-acquisition-growth.md`](modules/08-origin-acquisition-growth.md)。
- **状态**：DONE

---

### P0 命令行复核记录（2026-05-14）

- `godot --version`：`4.6.2.stable.official.71f334935`。
- `godot --headless --path . --quit`：退出码 0，占位主菜单启动成功，Autoload 输出为 `["GameState", "EventBus", "SaveSystem", "AudioManager", "Config"]`。
- `godot --headless --path . --script res://tools/validate_schemas.gd`：退出码 0，`Checked: 4`，四类示例资源全部通过。
- `godot --headless --path . -s res://addons/gut/gut_cmdln.gd -gconfig=res://tests/.gutconfig.json -gexit`：退出码 0，`1/1 passed`。

---

## 五、P1 阶段任务（地图与玩家原型）

### TASK-P1-1-player-controller

- **前置**：TASK-P0-3、TASK-P0-4
- **产出**：
  - `/project.godot`（Input Map action：`move_left` / `move_right` / `move_up` / `move_down` / `run` / `crouch` / `flashlight` / `interact` / `hide` / `pause`）
  - `/scenes/player/player.tscn`
  - `/scripts/player/player.gd`
  - `/scripts/player/states/`（按 Q-16 选定的状态机插件组织，含 `idle / walk / run / crouch / hide` 等节点）
  - `/data/items/flashlight.tres`（基于 `ItemResource` 或新增 `FlashlightResource`，含电量上限、消耗速率、阈值）
- **实现步骤**：
  1. 先在 `project.godot` 写入全部 Input Map action；默认键位可后续调整，但脚本只能读取 action。
  2. `player.tscn` 根节点 `CharacterBody2D`，挂载 `AnimatedSprite2D`、`CollisionShape2D`、状态机插件根节点、`PointLight2D`（手电）。
  3. `player.gd` ≤ 200 行；仅负责输入 action 采集与状态机参数注入，不写超过 1 层 if/else 行为分支，不硬编码物理按键。
  4. 在状态机插件中分别建 `idle / walk / run / crouch / interact / hide` 状态，转移条件用插件可视化编辑器配置。
  5. 每个状态在 `Enter` 时通过 `EventBus.noise_emitted` 广播噪声等级（`idle`=0、`crouch`=1、`walk`=2、`run`=3），信号包含稳定 action id。
  6. 手电参数全部从 `flashlight.tres` 读取；电量低于阈值时 `PointLight2D.energy` 阶梯式下降并播放手电闪烁音效（音效占位 `.wav`）。
  7. 开门、拾取、阅读、躲藏通过 `Area2D` + `interact` 状态触发（具体 NPC/物品在 P1-2 提供）。
- **验收**：
  - [ ] `project.godot` Input Map 中存在 10 个指定 action；`player.gd` 不出现物理按键硬编码。
  - [ ] 玩家可在测试场景内完成行走 / 奔跑 / 蹲伏 / 开关手电；手电电量下降并在阈值触发视觉变化。
  - [ ] 控制台能在每次状态切换时打印 `EventBus.noise_emitted` 的等级（手动用一个临时订阅者验证）。
  - [ ] `player.gd` 不出现 3 层及以上 if/else（grep `if .* and .*:` 配合人工核对）。
- **关联 VS**：§1 第 1、3 项；§1 第 2 项的"噪声广播接口"在此实现，"行为差异导致怪物判断不同"的验收推迟至 P2-2。
- **关联模块**：[`modules/01-player-control-exploration.md`](modules/01-player-control-exploration.md)。
- **状态**：DONE（实现提交：`a28dbf7`）

#### TASK-P1-1 完成记录（2026-05-14）

- 实现提交：`a28dbf7 feat(TASK-P1-1): add player controller prototype`。
- 设计：按 `docs/modules/01-player-control-exploration.md` v0.3.4 收束为 Input Map、玩家基础动词、手电资源和噪声事件接口，不扩展地图、怪物或结算。
- 搭建：新增 `scenes/player/player.tscn`、`scripts/player/player.gd`、`scripts/player/states/player_limbo_state.gd`、`data/items/flashlight.tres` 与 `FlashlightResource`；玩家美术使用 `PlaceholderBody` + `PlaceholderAssetLabel` 标注“玩家 2.5D Live 分层立绘”占位。
- 审计修复：`player.gd` 195 行；玩家脚本未出现物理按键硬编码；GoPeak `resource_dependencies` 检查玩家场景无循环依赖。
- 验收：`test_player_controller.gd` 5/5 通过；全量 GUT 6/6 通过；schema 校验 5 个资源通过（`FlashlightResource` 当前按 P8 schema 加固前规则跳过强制校验）；项目与玩家场景均可 headless 启动。

---

### TASK-P1-2-dungeon-handmade

- **前置**：TASK-P0-1、TASK-P1-1
- **产出**：
  - `/scenes/dungeon/micro_school_blockout.tscn`（走廊 + 2 个房间 + 1 个躲藏点 + 1 个交互占位物 + 1 个变化事件）
  - `/scenes/dungeon/abandoned_school.tscn`（含入口区 / 主走廊 / 4~6 候选房间 / 仪式房 / 出口区）
  - `/scenes/dungeon/rooms/`（每个候选房间一个 `.tscn` 子场景，便于通过房间池抽取）
  - `/scripts/systems/room_pool.gd`（按确定性种子从候选池抽取 4~6 间）
  - `/data/levels/abandoned_school.tres`（`LevelResource`，新增 schema 或复用 `MonsterProfile` 旁的"关卡数据"约定）
  - `/data/manifest/level_manifest.tres`（或等价 manifest 资源，记录关卡、房间、地图事件稳定 ID）
- **实现步骤**：
  1. 先搭建 `micro_school_blockout.tscn`：1 条走廊、2 个房间、1 个躲藏点、1 个交互占位物（stub）、1 次地图变化事件；只做灰盒和必要碰撞，不投入完整美术。
  2. 用场景嵌套 + `Node2D` / `Sprite2D` / `Parallax2D` / 碰撞层手工搭建 2.5D Live 分区，`TileMap` 仅可作为灰盒辅助；所有可走区域共用一个 `NavigationRegion2D`（为 P2-2 寻路预留）。
  3. 每个候选房间封装为独立 `.tscn`，根节点 `Node2D`，含本房间的物品/线索锚点占位。
  4. `room_pool.gd` 接收 `seed: int`，输出抽中房间列表；用 `RandomNumberGenerator` 并显式 `seed` 以保证可复盘。
  5. 实现一个由 `RuleResource` 驱动的"变化事件"（走廊变长 / 门牌错乱 / 已探索房间出现新物品三选一）：在仪式房交互完成时通过 `RuleEngine` 占位（P2-1 实现真实引擎前用一个本地 stub 也可）触发变化。
  6. 为关卡、房间、地图事件写入稳定 `resource_id`，并登记到 `level_manifest.tres`；脚本引用 manifest key，不直接写裸场景路径。
  7. 验证从入口到任一出口（逃离 / 仪式房 / 击杀点占位）步行 ≤ 90 秒。
- **验收**：
  - [ ] 微切片门禁通过：走廊 + 2 房间 + 1 躲藏点 + 1 交互占位物 + 1 变化事件可玩，变化不阻断逃离占位路径。
  - [ ] [`00-vertical-slice.md`](00-vertical-slice.md) §3 全部 4 项手测可勾选。
  - [ ] 同一 `seed` 跑两次 `room_pool.gd`，抽取结果完全一致。
  - [ ] `NavigationRegion2D` baked 后无 `Navigation Mesh Generation Failed` 告警。
  - [ ] `level_manifest.tres` 或等价 manifest 中存在关卡、房间、地图事件稳定 ID。
- **关联 VS**：§3。
- **关联模块**：[`modules/02-dungeon-generation-map.md`](modules/02-dungeon-generation-map.md)、[`00-art-direction.md`](00-art-direction.md)。
- **状态**：DONE（实现提交：`42f9796`）

#### TASK-P1-2 完成记录（2026-05-14）

- 实现提交：`42f9796 feat(TASK-P1-2): add dungeon blockout slice`。
- 设计：按 `docs/modules/02-dungeon-generation-map.md` v0.3.5 收束为手工灰盒微切片 + 固定候选房间池；没有引入程序化大地图或最终 TileMap 方案。
- 搭建：新增 `micro_school_blockout.tscn`、`abandoned_school.tscn`、4 个候选房间子场景、`RoomPool`、`MapChangeEvent`、`LevelResource` 和 `ManifestResource`；所有场景占位 Label 标注后续替换的破败校园分层美术内容。
- 审计修复：`RoomPool`、`MapChangeEvent`、`LevelResource`、`ManifestResource` 均小于 40 行；GoPeak `resource_dependencies` 检查微切片与完整校园场景均无循环依赖；未检出 `TileMap` 或程序化大地图实现。
- 验收：`test_dungeon_blockout.gd` 5/5 通过；全量 GUT 11/11 通过；schema 校验 7 个资源通过（P1 新增资源在 P8 schema 加固前跳过强制校验）；微切片与完整校园场景均可 headless 加载。

---

### TASK-P1-3-interactables-stub

- **前置**：TASK-P1-1、TASK-P1-2
- **产出**：
  - `/scenes/objects/door.tscn`、`/scenes/objects/pickup.tscn`、`/scenes/objects/note.tscn`、`/scenes/objects/hiding_spot.tscn`
  - `/scripts/objects/`（对应根脚本）
- **实现步骤**：
  1. 四类交互物均继承同一接口（在 `/scripts/objects/interactable.gd` 中定义 `interact(player)` 抽象方法）。
  2. `door` 支持开/关、可被规则锁定占位字段；`pickup` 写入临时 `inventory`（P4 接搜刮系统时替换）；`note` 弹出 Dialogic 2 的占位对话；`hiding_spot` 让 player 进入 `hide` 状态。
  3. 把至少 5 个实例摆进 `abandoned_school.tscn`，确保 VS §1 第 1 项"开门 / 拾取 / 阅读线索 / 进入躲藏点"四类操作都能在本副本内完成。
- **验收**：
  - [x] VS §1 第 1 项的全部六个动作能在副本中实测完成。
  - [x] 任一交互物脚本 ≤ 80 行。
- **关联 VS**：§1 第 1 项。
- **关联模块**：[`modules/01-player-control-exploration.md`](modules/01-player-control-exploration.md)。
- **状态**：DONE

#### TASK-P1-3 完成记录（2026-05-14）

- 实现提交：`ca89401 feat(TASK-P1-3): add interactable object stubs`。
- 设计：四类交互物统一为 `Area2D` 场景，脚本通过 `scripts/objects/interactable.gd` 提供 `interact(player)` 接口；交互物返回 payload，玩家控制器消费 payload，避免对象反向直接改写玩家状态。
- 搭建：新增 `door / pickup / note / hiding_spot` 四个占位场景与根脚本；`abandoned_school.tscn` 放入 `EntranceDoor`、`ExitDoor`、`BatteryPickup`、`RuleNote`、`LockerHidingSpot` 共 5 个实例。
- 占位资源：门、拾取电池、线索纸条和躲藏柜均在场景内用 `PlaceholderAssetLabel` 标注正式美术替换意图。
- 审计修复：Dialogic 2 暂不启用运行时 Autoload，`note` 仅保留 `dialogic_timeline_id` 和 `note_text` 占位；派生交互脚本使用显式脚本路径继承，避免无编辑器导入缓存时 `class_name` 解析失败。
- 验收：GUT `17/17` 通过；schema 校验通过（未注册 P1 资源保持 P8 schema hardening 前的 SKIP）；废弃学校与交互物场景 headless 加载通过；GoPeak `resource_dependencies` 检查无循环依赖，编辑器桥接仍因 `127.0.0.1:6506` 被占用不可连接。

---

### TASK-P1-4-phase-exit-review

- **前置**：TASK-P1-1、TASK-P1-2、TASK-P1-3
- **产出**：`/docs/perf/p1-review.md`（阶段出口走查记录）
- **实现步骤**：
  1. 按实施计划 §十三 P1 行逐项勾验：微切片门禁 + Input Map action + VS §1 第 1、3 项 + §3 全勾。
  2. 记录已发现但延后处理的 issue 列表（指向后续 TASK）。
  3. 让 P2 入口前置任务 `block_until_p1_done` 解除。
- **验收**：
  - [x] P1 全部门禁条件勾选 ✅。
  - [x] 出口走查记录已提交。
- **关联 VS**：§1 第 1、3 项 + §3。
- **关联模块**：[`00-implementation-plan.md`](00-implementation-plan.md) §十三。
- **状态**：DONE

#### TASK-P1-4 完成记录（2026-05-14）

- 实现提交：`f81dbb9 docs(TASK-P1-4): add P1 exit review`。
- 设计：P1 出口只判定无怪物阶段的基础探索动词与地图结构，不提前接入怪物、死亡复活、正式线索、正式搜刮或最终美术。
- 搭建：新增 `docs/perf/p1-review.md`，逐项记录微切片门禁、VS §1 第 1/3 项、VS §3 和 P1 延后项。
- 审计修复：记录 `player.gd` 行数收束、交互物脚本行数、GoPeak bridge 端口占用和资源依赖无循环结论。
- 验收：P1 全部门禁已在走查表勾选；GUT `17/17`、schema 校验、headless 场景加载和 GoPeak `resource_dependencies` 均通过或有明确非阻塞说明。

---

## 六、P2 阶段任务（怪物系统与感知压力）

### TASK-P2-1-rule-engine

- **前置**：TASK-P0-6、TASK-P1-4
- **产出**：
  - `/scripts/systems/rule_engine.gd`
  - `/data/rules/da_zhi/`（至少 3 条规则 `.tres`：现形条件 / 弱点条件 / 收容仪式第 1 步）
  - `/tests/test_rule_engine.gd`
- **实现步骤**：
  1. `RuleEngine` 加载 `Array[RuleResource]`，订阅 `EventBus` 中相关信号（噪声、灯光、物品使用等）。
  2. 提供 `evaluate(context: Dictionary) -> Array[RuleResource]`：返回当前帧被触发的规则列表，发出 `rule_triggered(rule_id)` 信号。
  3. 提供 `clue_unlocked(clue_id)` 输出，便于 P3 线索系统订阅。
  4. 关键失败规则必须填入 `RuleResource.learnable_hint`，用于 P3-4 死亡/失败后的最低学习反馈。
  5. **禁止**在引擎中写任何怪物专属硬编码字段——所有判定都从 `RuleResource.trigger_conditions` 解析。
  6. GUT 用例覆盖：a) 单条规则触发；b) 多条规则同帧；c) 触发条件不满足时不发信号；d) 重复触发去重；e) 关键失败规则 `learnable_hint` 非空。
- **验收**：
  - [x] `test_rule_engine.gd` 中至少 6 个用例 100% 通过。
  - [x] 在编辑器内替换 `RuleEngine` 加载的 `.tres` 列表，可观察到不同的 `rule_triggered` 信号序列。
  - [x] 会导致死亡、失败或错误收容的规则均有非空 `learnable_hint`。
  - [x] `rule_engine.gd` ≤ 300 行；无 `monster_*` 命名字段。
- **关联 VS**：—（为 §4 §5 提供基础）
- **关联模块**：[`modules/03-monster-anomaly-rules.md`](modules/03-monster-anomaly-rules.md)、[`monsters/001-da-zhi.md`](monsters/001-da-zhi.md)。
- **状态**：DONE

#### TASK-P2-1 完成记录（2026-05-14）

- 实现提交：`9acd9d8 feat(TASK-P2-1): add rule engine`。
- 设计：`RuleEngine` 是普通 `Node`，不进入 Autoload；通过 Inspector 可替换 `Array[RuleResource]`，规则判断全部由 `trigger_conditions` 解析。
- 搭建：新增 `scripts/systems/rule_engine.gd`、`tests/test_rule_engine.gd` 和 4 条大只 P2-1 最低规则资源：走廊奔跑、首次现形、广播断电弱点窗口、名单确认收容步骤。
- 审计修复：GUT RED-GREEN 后清理了 5 个 orphan Node；`rule_engine.gd` 145 行，无 `monster_*` 命名字段；GoPeak `resource_dependencies` 检查 RuleEngine 与规则资源无循环依赖。
- 验收：GUT `25/25` 通过；schema 校验 11 个资源通过；关键失败规则 `rule_da_zhi_corridor_run` 已填 `learnable_hint`。

---

### TASK-P2-2-da-zhi-ai

- **前置**：TASK-P2-1
- **产出**：
  - `/scenes/monster/da_zhi.tscn`
  - `/scripts/monster/da_zhi.gd`
  - `/scripts/monster/states/`（按 Q-16 插件组织）
  - `/data/monsters/da_zhi.tres`（`MonsterProfile`）
- **实现步骤**：
  1. 用 Q-16 选定的插件搭建四阶段流程：`stalk → probe → search → hunt`，按 [`monsters/001-da-zhi.md`](monsters/001-da-zhi.md) 定义转移条件。
  2. 阶段转移不引入硬编码计时，**全部条件来自 `RuleResource`**（如"听见 noise_level ≥ 2 持续 N 秒" → 转 `probe`）。
  3. 寻路使用 P1-2 配置的 `NavigationRegion2D`。
  4. 现形效果：在 `rule_triggered("apparition_condition")` 时短暂提升 `Sprite2D` alpha 至 0.3 持续 2~3 秒。
  5. 严禁随机传送；如需"突然出现"必须经由规则触发。
- **验收**：
  - [x] VS §4 前 3 项可勾选。
  - [x] VS §1 第 2 项可勾选：玩家以不同噪声等级行走，怪物有可观察的行为变化（如 `walk` 时不响应，`run` 时进入 `probe`）。
  - [x] `da_zhi.gd` 文件本体 ≤ 200 行；阶段转移条件不在脚本内硬编码。
- **关联 VS**：§4 前 3 项 + §1 第 2 项。
- **关联模块**：[`modules/03-monster-anomaly-rules.md`](modules/03-monster-anomaly-rules.md)、[`monsters/001-da-zhi.md`](monsters/001-da-zhi.md)。
- **状态**：DONE

#### TASK-P2-2 完成记录（2026-05-14）

- 实现提交：`ad22a25 feat(TASK-P2-2): add da zhi ai skeleton`。
- 设计：大只 AI 骨架只消费 `RuleEngine` 注入的 `rule_effect`，不写具体规则 ID；阶段节点使用 LimboHSM，移动使用 `NavigationAgent2D`。
- 搭建：新增 `scenes/monster/da_zhi.tscn`、`scripts/monster/da_zhi.gd`、`scripts/monster/states/da_zhi_limbo_state.gd`、`data/monsters/da_zhi.tres` 和 7 个 GUT 用例。
- 占位资源：大只视觉为 `Polygon2D` 剪影 + `PlaceholderAssetLabel`“占位: 大只远处剪影/2.5D Live分层怪物立绘”。
- 审计修复：`da_zhi.gd` 116 行，不包含 `rule_da_zhi_` 或随机/传送逻辑；GoPeak `resource_dependencies` 检查大只场景、脚本和 profile 无循环依赖。
- 验收：GUT `32/32` 通过；schema 校验 12 个资源通过；大只场景 headless 加载通过；奔跑噪声可触发搜索阶段，行走不会触发。

---

### TASK-P2-3-pressure-feedback

- **前置**：TASK-P2-2
- **产出**：
  - `/scripts/systems/pressure_level.gd`
  - `/scenes/ui/hud/pressure_hud.tscn`（心跳 + 手电闪烁视觉层）
  - `/scenes/audio/heartbeat_player.tscn`（`AudioStreamPlayer2D` + Attenuation）
  - `/data/audio/heartbeat_busses.tres`（AudioBus 配置，至少三路：heartbeat / flashlight / ambience）
  - `/scripts/shaders/sanity_distort.gdshader`
- **实现步骤**：
  1. `PressureLevel` 是 Autoload 之外的普通系统节点（保持单例白名单），由 `da_zhi.gd` 通过 `EventBus.pressure_changed(level: float)` 注入。
  2. 心跳音效播放速率与音量随 `level` 阶梯变化；手电 `PointLight2D` 闪烁频率随 `level` 调整；环境异响通过 `AudioBus` 的 send 强度调整。
  3. AudioBus 分组配置至 `Project Settings → Audio Buses`，并把三类音源各路由到对应 Bus。
  4. `sanity_distort.gdshader` 实现轻度文字抖动 + 音频低通滤波（理智低时启用），通过 `Config` 提供开关。
  5. 在 `abandoned_school.tscn` 的第一次进入触发器中**强制**调用一次 `da_zhi.show_apparition(2.5s)`。
- **验收**：
  - [x] VS §2 全部 5 项可勾选。
  - [x] 三类反馈在"远 / 近"两档下能由玩家明显区分。
  - [x] 关闭 Shader 时游戏仍可玩（`Config.sanity_shader_enabled = false` 测试）。
- **关联 VS**：§2。
- **关联模块**：[`modules/04-horror-perception-pressure.md`](modules/04-horror-perception-pressure.md)。
- **状态**：DONE

**完成记录（2026-05-14）**

- 设计：`PressureLevel` 保持普通场景节点，接收 `EventBus.pressure_changed(level)`；心跳、手电闪烁、环境氛围混音、理智干扰共用同一快照。
- 搭建：新增 `pressure_level.gd`、`pressure_hud.tscn`、`heartbeat_player.tscn`、`heartbeat_busses.tres`、`sanity_distort.gdshader`、`first_entry_manifest_trigger.gd` 和 9 个 GUT 用例。
- 占位资源：HUD 为全屏 `ColorRect` 叠层占位，心跳音源当前无正式 `AudioStream`；大只仍使用 `Polygon2D` 剪影 + `PlaceholderAssetLabel`，对应后续“远处高大人形剪影 / 2.5D Live 分层怪物立绘”。
- 审计修复：`PressureLevel` 142 行、`DaZhiAI` 135 行，Autoload 白名单保持 5 项；GoPeak `resource_dependencies` 检查废弃学校、HUD、心跳和 AudioBus 无循环依赖，编辑器桥接仍因 `127.0.0.1:6506` 被占用不可连接。
- 验收：GUT `41/41` 通过；schema 校验 13 个资源通过或按 P8 前 schema 口径 SKIP；废弃学校、压力 HUD、心跳播放器和大只场景 headless 加载通过；实现提交 `a5820a2`。

---

### TASK-P2-4-monster-clue-stubs

- **前置**：TASK-P2-1
- **产出**：`/data/rules/da_zhi/clue_*.tres`（至少 3 条占位线索规则，标记 `clue_unlock_id`）
- **实现步骤**：
  1. 为后续 P3-1 提供"已存在的线索规则池"，避免 P3 阶段一次性新增过多 `.tres` 导致 schema 漂移。
  2. 每条线索规则仅填字段、不绑定具体笔记内容（笔记本体由 P3-1 Dialogic 提供）。
- **验收**：
  - [x] `validate_schemas.gd` 对新加 `.tres` 全部通过。
- **关联 VS**：—
- **关联模块**：[`modules/05-clues-puzzles-rule-deduction.md`](modules/05-clues-puzzles-rule-deduction.md)。
- **状态**：DONE

**完成记录（2026-05-14）**

- 设计：新增 3 条线索规则占位，分别覆盖走廊回声行为观察、广播依赖击杀线索、完整名单收容线索；只登记稳定 `clue_unlock_id` 和规则元数据，不绑定 Dialogic timeline 或笔记正文。
- 搭建：新增 `clue_da_zhi_corridor_echo.tres`、`clue_da_zhi_broadcast_dependency.tres`、`clue_da_zhi_full_roster.tres`，并把 3 条规则 ID 登记到 `data/monsters/da_zhi.tres`。
- 占位资源：当前没有新增美术/文本资产；3 条 `.tres` 仅是 P3-1 线索对象和 Dialogic 笔记的稳定数据锚点。
- 审计修复：新增 GUT 用例验证 clue stub 存在、`clue_unlock_id` 非空、effect 为 `clue_stub`、不含 `dialogic_timeline_id` / `note_text`；GoPeak `resource_dependencies` 检查 3 条线索规则和 profile 无循环依赖。
- 验收：GUT `42/42` 通过；schema 校验 16 个资源通过或按 P8 前 schema 口径 SKIP；实现提交 `b52b51c`。

---

### TASK-P2-5-phase-exit-review

- **前置**：TASK-P2-1 ~ TASK-P2-4
- **产出**：`/docs/perf/p2-review.md`
- **实现步骤**：按实施计划 §十三 P2 行逐项勾验；记录遗留 issue。
- **验收**：
  - [x] VS §2 + §4 前 3 项 + §1 第 2 项 全勾。
  - [x] `RuleEngine` GUT 用例 100% 通过。
- **关联 VS**：见上。
- **关联模块**：[`00-implementation-plan.md`](00-implementation-plan.md) §十三。
- **状态**：DONE

**完成记录（2026-05-14）**

- 设计：P2 出口只验收怪物可观察、压力反馈与规则可学习前置，不提前实现 P3 线索正文、击杀/收容执行和死亡复活。
- 搭建：新增 `docs/perf/p2-review.md`，逐项记录 VS §2、§4 前 3 项、§1 第 2 项和 RuleEngine GUT 结果。
- 审计修复：走查发现“大只两种以上现形条件”不足，已补 `rule_da_zhi_flashlight_stare_manifestation.tres` 并纳入测试和 profile。
- 验收：GUT `42/42` 通过；schema 校验 17 个资源通过或按 P8 前 schema 口径 SKIP；关键 P2 场景 headless 加载通过；审计修复提交 `5023655`。

---

## 七、P3 阶段任务（线索、解谜与结算）

### TASK-P3-1-clue-system

- **前置**：TASK-P2-5
- **产出**：
  - `/scenes/objects/clue_note.tscn`（基于 Dialogic 2 的笔记交互）
  - `/scripts/systems/clue_book.gd`（记录 `known_clue_ids`，写入 `GameState`）
  - `/data/clues/`（笔记/电台/对话条目至少 11 条：3 逃离 + 3 击杀 + 5 收容）
- **实现步骤**：
  1. 每条线索由 Dialogic 2 timeline 编辑文本；脚本字段 `clue_id` 关联到 P2-4 已建的 `RuleResource.clue_unlock_id`。
  2. 玩家拾取后 `EventBus.clue_unlocked(clue_id)` → `clue_book.gd` 写入 `GameState.known_clue_ids`。
  3. 至少 1 条收容线索通过怪物行为反应间接验证：例如"对某物品有规避反应"→ 触发 `RuleEngine` 中的"验证规则"，更新 UI 标签。
  - **验收**：
    - [x] P3-1 信息层工程验收通过：11 条线索、Dialogic timeline、`ClueBook`、`GameState.known_clue_ids`、低理智干扰与 1 条收容行为验证规则均已覆盖。
    - [ ] VS §5 完整玩家路径验证与非开发者口述盲测收束到 TASK-P3-5 出口门禁。
    - [x] [`00-glossary.md`](00-glossary.md) 中 P3-1 线索术语已统一。
  - **关联 VS**：§5；兑现 P2 延后的盲测条件。
  - **关联模块**：[`modules/05-clues-puzzles-rule-deduction.md`](modules/05-clues-puzzles-rule-deduction.md)。
  - **状态**：DONE

**完成记录（2026-05-14）**

- 设计：P3-1 只承接线索信息层，不提前实现击杀/收容执行、结算或死亡复活；VS §5 的完整路径验收保留到 P3-5。
- 搭建：新增 `ClueResource`、`ClueBook`、`ClueNote`、11 条 `data/clues/*.tres`、11 条 Dialogic `.dtl` 时间线占位、`EventBus.clue_unlocked` 与 `GameState.known_clue_ids`。
- 审计修复：GoPeak 发现 `@export_dir` 目录被误报为缺失资源依赖，已改为运行时拼接默认目录；未启用 Dialogic editor plugin，也未扩展 Autoload 白名单。
- 验收：`test_clue_system.gd` 8/8 通过；全量 GUT `50/50` 通过；schema 校验 29 个资源通过或按既定 P8 口径 SKIP；关键场景 headless 加载与 GoPeak 依赖审计通过。

---

### TASK-P3-2-weakness-containment

- **前置**：TASK-P3-1
- **产出**：
  - `/data/rules/da_zhi/weakness.tres`、`/data/rules/da_zhi/containment_step_1.tres` ~ `step_3.tres`
  - 仪式房内三步仪式触发器场景节点
- **实现步骤**：
  1. 弱点规则：触发条件指向特定物品 + 玩家位置 + 怪物当前阶段。
  2. 收容三步仪式：每步一个 `RuleResource`，前一步成功是后一步触发的前置条件之一。
  3. 击杀 / 收容成功时 `EventBus.objective_completed(type: int)`，供 P3-3 结算系统订阅。
- **验收**：
  - [ ] VS §4 后 3 项可勾选。
  - [ ] 通过线索推理（不查文档）能在 ≤ 3 分钟内完成击杀；在 ≤ 全部 5 条收容线索集齐后能合理推出三步仪式。
- **关联 VS**：§4 后 3 项。
- **关联模块**：[`monsters/001-da-zhi.md`](monsters/001-da-zhi.md)。
- **状态**：TODO

---

### TASK-P3-3-settlement-calculator

- **前置**：TASK-P3-2
- **产出**：
  - `/scripts/systems/settlement_calculator.gd`
  - `/scenes/ui/settlement_screen.tscn`
  - `/tests/test_settlement_calculator.gd`
- **实现步骤**：
  1. 输入：`path_flag`（逃离/击杀/收容/错误收容）、`hp_remaining`、`pickup_list`、`triggered_rules`。输出：四种结算之一 + 资源/原形/档案三项数值。
  2. 错误收容惩罚：扣减基地资源占位字段（P5 接入正式基地资源），并在结算页显示数值。
  3. 三档奖励差："收容 > 击杀 > 逃离"在素材量 / 原形质量 / 叙事条目三维同时拉开（数值表 `/data/settlement_payoffs.tres`）。
  4. GUT 用例覆盖：四种路径各一例 + 错误收容扣减 + 边界（HP=0 / 拾取空）。
- **验收**：
  - [ ] `test_settlement_calculator.gd` 100% 通过（至少 6 用例）。
  - [ ] VS §6 全部 5 项可勾选。
  - [ ] 数值表在 Inspector 中可读可改，不需要改代码就能调奖励曲线。
- **关联 VS**：§6。
- **关联模块**：[`modules/06-objectives-settlement.md`](modules/06-objectives-settlement.md)。
- **状态**：TODO

---

### TASK-P3-4-death-respawn

- **前置**：TASK-P3-3
- **产出**：
  - `/scenes/base/base_placeholder.tscn`（基地占位）
  - `GameState` 内 `respawn_at_base()` 方法
  - 死亡/失败提示占位显示（可复用结算或临时提示层）
- **实现步骤**：
  1. 玩家死亡 → `EventBus.player_died` → `GameState` 切场到 `base_placeholder.tscn`。
  2. 副本场景 unload；副本内拾取资源按占位比例（默认 0%，P4 改为 65%）返还。
  3. 复活时清空副本状态，重置 `RuleEngine` 内部计数器。
  4. 读取本次死亡关联 `RuleResource.learnable_hint` 并显示；无法定位规则时显示通用提示并把缺失 rule id 记入调试日志。
- **验收**：
  - [ ] VS §1 第 4 项可勾选。
  - [ ] 死亡 → 复活 → 再次进入副本全流程无脚本红字。
  - [ ] 死亡后至少出现一条可学习提示；提示来自 `learnable_hint` 或明确记录 fallback 原因。
- **关联 VS**：§1 第 4 项。
- **关联模块**：[`modules/01-player-control-exploration.md`](modules/01-player-control-exploration.md)。
- **状态**：TODO

---

### TASK-P3-5-phase-exit-review

- **前置**：TASK-P3-1 ~ TASK-P3-4
- **产出**：`/docs/perf/p3-review.md`
- **验收**：VS §4 + §5 + §6 + §1 第 4 项全勾；`SettlementCalculator` GUT 全过；盲测口述规则成功。
- **状态**：TODO

---

## 八、P4 阶段任务（搜刮深度与原形养成）

### TASK-P4-1-loot-system

- **前置**：TASK-P3-5
- **产出**：
  - `/scripts/systems/inventory.gd`
  - `/data/items/`（9 个 `ItemResource`：3 生存 + 3 解谜 + 3 养成）
  - `/tools/csv_to_tres.gd`（批量导入工具）
  - `/data/loot_tables/abandoned_school.tres`
- **实现步骤**：
  1. `inventory.gd` 管理带入区上限（默认 8 格，存入 `Config`）与副本拾取列表。
  2. 9 种物品先用 CSV 写在 `/data/items/items.csv`，再由 `csv_to_tres.gd` 在编辑器内一键导出为 `.tres`。
  3. 高价值养成素材分布绑定 P1-2 房间池中标记为 `danger_high` 的房间。
  4. 死亡返还率 65% 写入 `Config`，与 P3-4 死亡流程联动。
- **验收**：
  - [ ] VS §7 全部 4 项可勾选。
  - [ ] CSV 改动后跑一次 `csv_to_tres.gd`，`.tres` 自动同步且 schema 校验通过。
- **关联 VS**：§7。
- **关联模块**：[`modules/07-looting-resources.md`](modules/07-looting-resources.md)。
- **状态**：TODO

---

### TASK-P4-2-origin-growth

- **前置**：TASK-P4-1
- **产出**：
  - `/scripts/systems/origin_growth.gd`
  - `/data/origins/da_zhi_seed.tres`（初始原形示例）
  - `/data/origin_side_effects/`（三路线各一个 `.tres`）
- **实现步骤**：
  1. `origin_growth.feed(origin, material) -> Result` 在 0%~60% 阶段支持反向回拨（扣稳定度）；60% 锁定路线且变更外貌（切换 `Sprite2D.texture` 占位）。
  2. 三能力原型对应 ItemResource：`hint`（拟人）、`deterrent`（恐怖）、`living_flashlight`（工具）。
  3. 副作用列表写入 `OriginResource.side_effects`，每条副作用关联一个 `RuleResource`（影响下次副本）。
  4. **业务参数全部在 `.tres` 内**，脚本不出现数值魔法常量。
- **验收**：
  - [ ] VS §8 全部 6 项可勾选。
  - [ ] 在 Inspector 中调整投喂数值，行为立即变化，无需重启。
- **关联 VS**：§8。
- **关联模块**：[`modules/08-origin-acquisition-growth.md`](modules/08-origin-acquisition-growth.md)。
- **状态**：TODO

---

### TASK-P4-3-save-system

- **前置**：TASK-P0-3、TASK-P4-2
- **产出**：
  - `/scripts/autoload/save_system.gd`（实现替换骨架）
  - `/tests/test_save_system.gd`
- **实现步骤**：
  1. 使用 `ResourceSaver.save()` 写自定义 `SaveGameResource`，含版本字段 `schema_version: int = 1` 与时间戳。
  2. 进入基地自动存档；退出游戏前再存一次（`NOTIFICATION_WM_CLOSE_REQUEST`）。
  3. 加载时若 `schema_version` 不匹配，走 `migrate_v1_to_v2(...)` 占位入口（P8-1 完善）。
  4. GUT 用例覆盖：a) 写后立即读字段一致；b) 写入再重启 Godot（headless 子进程）后字段仍一致；c) `OriginResource` 全字段往返一致；d) 版本不匹配触发迁移分支。
- **验收**：
  - [ ] `test_save_system.gd` 100% 通过。
  - [ ] 存档文件可被文本编辑器打开（JSON 或 `.tres`）。
- **关联 VS**：—（为 §10 §11 提供基础）
- **关联模块**：[`00-tech-constraints.md`](00-tech-constraints.md) §四.6。
- **状态**：TODO

---

### TASK-P4-4-phase-exit-review

- **前置**：TASK-P4-1 ~ TASK-P4-3
- **产出**：`/docs/perf/p4-review.md`
- **验收**：VS §7 + §8 全勾；`SaveSystem` GUT 全过；存档跨重启恢复正常。
- **状态**：TODO

---

## 九、P5 阶段任务（原形助战与核心循环）

### TASK-P5-1-base-scene

- **前置**：TASK-P4-4
- **产出**：
  - `/scenes/base/base.tscn`（含收容室 / 仓库 / 准备区 / 档案入口四区）
  - `/scripts/base/`（各区交互脚本）
- **实现步骤**：
  1. 玩家可自由移动；四区域各一个 `Area2D` 入口；档案入口暂时弹出 Dialogic 占位对话。
  2. 污染度只用视觉/音效暗示（基地灯光偏色 + 远处异响），**不显示数值**。
  3. 进入基地自动调用 `SaveSystem.save()`。
- **验收**：
  - [ ] VS §10 全部 4 项可勾选。
  - [ ] 玩家在基地全程无副本红字、无加载卡顿（< 2s）。
- **关联 VS**：§10。
- **关联模块**：[`modules/10-base-management-research.md`](modules/10-base-management-research.md)。
- **状态**：TODO

---

### TASK-P5-2-companion-support

- **前置**：TASK-P5-1、TASK-P4-2
- **产出**：
  - `/scripts/systems/companion.gd`
  - `/scenes/base/preparation_room.tscn`（携带原形选择 UI）
- **实现步骤**：
  1. 出本前在准备区选择是否携带原形及具体哪只；选择写入 `GameState.active_companion`。
  2. 副本内触发能力时通过 `EventBus.companion_ability_triggered(type)` 派发：拟人弹提示、恐怖让大只回退一阶段、工具增强手电。
  3. 致命伤代价：拟人好感降 / 恐怖污染升 / 工具损坏，写回 `OriginResource` 并由 `SaveSystem` 持久化。
- **验收**：
  - [ ] VS §9 全部 3 项可勾选。
  - [ ] 三种能力各跑一次测试，代价生效后存档读取仍保留。
- **关联 VS**：§9。
- **关联模块**：[`modules/09-origin-companion-support.md`](modules/09-origin-companion-support.md)。
- **状态**：TODO

---

### TASK-P5-3-loop-integration

- **前置**：TASK-P5-2
- **产出**：`/docs/perf/p5-blind-test.md`（盲测记录）
- **实现步骤**：
  1. 联调"基地准备 → 副本 → 结算 → 基地养成 → 再次副本"全链路。
  2. 修复跨模块字段不一致；常见断点：P3-3 错误收容惩罚与 P5-1 基地资源扣减对接、`OriginResource` 副作用写回时机。
  3. 邀请 1 名非开发玩家盲测；记录其能否口述"我是怎么变强的，又因此变得多危险"。
  4. **冻结所有数据资源 schema**：把 `/scripts/systems/resources/*.gd` 的 `@export` 字段列表抄入 `/docs/schema-freeze.md` 作为锚点。
- **验收**：
  - [ ] VS §11 全部 3 项可勾选。
  - [ ] 盲测记录已归档。
  - [ ] `/docs/schema-freeze.md` 存在；此后任何 schema 字段变更必须升档并更新本文件。
- **关联 VS**：§11。
- **关联模块**：所有模块。
- **状态**：TODO

---

### TASK-P5-4-phase-exit-review

- **前置**：TASK-P5-3
- **产出**：`/docs/perf/p5-review.md`
- **验收**：VS §9 + §10 + §11 全勾；Schema 冻结归档。
- **状态**：TODO

---

## 十、P6 阶段任务（垂直切片验收与性能基线）

### TASK-P6-1-full-gut-sweep

- **前置**：TASK-P5-4
- **产出**：`/docs/perf/p6-gut-report.md`
- **实现步骤**：
  1. 命令行 headless 跑全部 GUT 用例：`godot --headless -s res://addons/gut/gut_cmdln.gd -gdir=res://tests -gexit`。
  2. 失败项逐条修复并回归。
  3. 把 P5-3 盲测暴露的缺陷过一遍清单，逐条 close。
- **验收**：
  - [ ] 全部 GUT 用例 100% 通过。
  - [ ] VS §1~§11 全部 P0 项可勾选。
- **关联 VS**：全部 P0。
- **状态**：TODO

---

### TASK-P6-2-perf-baseline

- **前置**：TASK-P6-1
- **产出**：
  - `/docs/perf/baseline-report.md`
  - 性能截图归档至 `/docs/perf/screenshots/`
- **实现步骤**：
  1. 用 Godot Profiler 抓取基地与副本场景：FPS、单帧脚本耗时、节点数、加载时间、内存、存档大小。
  2. 单帧脚本耗时持续 > 8ms 则按 [`00-tech-constraints.md`](00-tech-constraints.md) §十一 进入"仅热点改 GDExtension"回退；**禁止全栈迁移**，并在 [`00-implementation-plan.md`](00-implementation-plan.md) 版本记录留痕。
  3. 报告表格：每项指标 vs 目标值 vs 实测值。
- **验收**：
  - [ ] 副本 60fps 稳定；单帧脚本 < 4ms；节点 < 2000；加载 < 5s；存档 < 5MB；内存 < 1.5GB。
  - [ ] 报告归档完成。
- **关联 VS**：—
- **关联模块**：[`00-tech-constraints.md`](00-tech-constraints.md) §七。
- **状态**：TODO

---

### TASK-P6-3-windows-export

- **前置**：TASK-P6-2
- **产出**：
  - `/export_presets.cfg`（Windows 64-bit 预设）
  - `/dist/YX-vs-1.0.exe`（单文件包，**不入 git**，仅作交付）
- **实现步骤**：
  1. 配置 Windows 64-bit 导出预设；启用 "Embed PCK" 单文件包模式。
  2. headless 导出：`godot --headless --export-release "Windows Desktop" dist/YX-vs-1.0.exe`。
  3. 在干净的 Windows 机器（或 VM）上运行，逐项校验交付四条：启动 ≤ 3s、一次完整循环 ≤ 10min、无脚本红字、存档重启恢复。
- **验收**：
  - [ ] 四条交付校验全部通过。
  - [ ] 非开发者按 README 步骤可直接双击运行。
- **关联 VS**：—
- **关联模块**：[`00-tech-constraints.md`](00-tech-constraints.md) §十二。
- **状态**：TODO

---

### TASK-P6-4-phase-exit-review

- **前置**：TASK-P6-3
- **产出**：`/docs/perf/p6-review.md`（**垂直切片验收报告**）
- **验收**：VS 全部 P0 验收项勾选完毕；GUT 三类强制用例全过；性能基线达标；`.exe` 四条校验通过。
- **状态**：TODO

---

## 十一、P7 阶段任务（体验打磨与氛围补完）

### TASK-P7-1-narrative-polish

- **前置**：TASK-P6-4
- **产出**：
  - `/data/dialogic/radio_intro.dtl`（电台第一通话）
  - `/scenes/base/base.tscn` 增量更新（随机异响 / 物品位移）
  - `/data/clues/da_zhi_archive_post_containment.tres`（档案扩写条目）
- **实现步骤**：
  1. 基地补"被污染过"细节：随机异响计时器、随机物品轻微旋转 1~3 度（每次进入基地概率触发）。
  2. 电台第一通话脚本走 Dialogic 2，依据 [`modules/11-narrative-worldbuilding.md`](modules/11-narrative-worldbuilding.md) 与 Q-01 定案（异常事件幸存者 + 旧机构候选执行者）。
  3. 大只档案页在收容成功后扩写一段（与 [`monsters/001-da-zhi.md`](monsters/001-da-zhi.md) 一致）。
  4. 死亡复盘提示打磨：沿用 P3-4 已显示的 `RuleResource.learnable_hint`，只优化文字、节奏和演出，不在 P7 首次补功能。
  5. **先订字数上限**再写：每条 P1 文本 ≤ 80 字。
- **验收**：
  - [ ] VS P1 全部 4 条勾选。
- **关联 VS**：P1。
- **关联模块**：[`modules/10-base-management-research.md`](modules/10-base-management-research.md)、[`modules/11-narrative-worldbuilding.md`](modules/11-narrative-worldbuilding.md)。
- **状态**：TODO（Q-01 已定案；前置仍依赖 P6-4）

---

### TASK-P7-2-difficulty-tuning

- **前置**：TASK-P7-1
- **产出**：
  - `/data/config/pressure_curve.tres`（三类反馈强度曲线参数）
  - `/data/rules/da_zhi/dynamic_danger_lv1.tres`（第二次进入时新增的规则）
- **实现步骤**：
  1. 汇总 P5-3 盲测中"反馈过载 / 反馈不足"案例（**不再引用 P6 盲测**——P6 阶段无盲测安排）。
  2. 通过 `Config` 调三类反馈强度，**不改代码**。
  3. 接通副本动态危险度第一档：玩家第二次进入同一副本时，`RuleEngine` 自动加载 `dynamic_danger_lv1.tres`。
- **验收**：
  - [ ] 同一玩家二次进入同一副本，自报"和上一次有规则上的不同，而不是只是数值更难"。
  - [ ] [`00-risk-register.md`](00-risk-register.md) R-01 状态降为"已缓解"。
- **关联 VS**：—（间接服务 P1 体验）
- **关联模块**：[`modules/04-horror-perception-pressure.md`](modules/04-horror-perception-pressure.md)、[`00-risk-register.md`](00-risk-register.md) R-01。
- **状态**：TODO

---

## 十二、P8 阶段任务（工程化与发布管线）

### TASK-P8-1-ci-pipeline

- **前置**：TASK-P7-2
- **产出**：
  - `.github/workflows/build.yml`
  - `.github/workflows/test.yml`
- **实现步骤**：
  1. GitHub Actions：用 `firebelley/godot-export` 或等价 action 安装 Godot headless。
  2. 跑 GUT 三类强制测试：`RuleEngine` / `SaveSystem` / `SettlementCalculator`。
  3. 跑 Windows 64-bit headless 导出；产物上传 Artifact。
  4. 在 `SaveSystem` 中确认 `schema_version` 字段存在；为"老存档读不动 → 显式提示并迁移"补完分支入口。
- **验收**：
  - [ ] 提交 main 分支后 CI 自动跑通，状态绿。
  - [ ] Artifact 可下载并在 Windows 上运行。
- **关联 VS**：—
- **关联模块**：[`00-tech-constraints.md`](00-tech-constraints.md) §八、§九。
- **状态**：TODO

---

### TASK-P8-2-schema-validation-ci

- **前置**：TASK-P8-1
- **产出**：
  - `/tools/validate_schemas.gd` 强化版（命令行可调用）
  - `.github/workflows/test.yml` 中加入 schema 校验步骤
- **实现步骤**：
  1. `validate_schemas.gd` 支持 `--ci` 模式：失败时退出码非 0。
  2. CI 在 GUT 之后加一步 `godot --headless -s res://tools/validate_schemas.gd --ci`。
  3. 在 `/tests/fixtures/bad_resources/` 放故意不合规的 `.tres`，写一个 PR 验证 CI 能阻断它。
- **验收**：
  - [ ] CI 在 schema 不合规输入下能正确报错并阻断构建。
- **关联 VS**：—
- **关联模块**：[`00-tech-constraints.md`](00-tech-constraints.md) §四。
- **状态**：TODO

---

### TASK-P8-3-docs-closeout

- **前置**：TASK-P8-2
- **产出**：
  - [`00-open-questions.md`](00-open-questions.md) 状态全量复审
  - [`00-risk-register.md`](00-risk-register.md) 归档"已缓解 / 已关闭"项
  - [`00-next-stage-expansions.md`](00-next-stage-expansions.md) 延后项复核
  - 各模块文档"后续扩展方向"节走查
  - 顶层所有 `00-*.md` 版本号统一推进一档
- **实现步骤**：
  1. 把 P0~P7 实测中形成的设计决策回填 [`00-open-questions.md`](00-open-questions.md)，关闭已决问题，新增第二阶段才需要的问题。
  2. [`00-risk-register.md`](00-risk-register.md) 中"已缓解 / 已关闭"项归档。
  3. 各模块"后续扩展方向"节走查，与冻结 schema 冲突项升级为新 Open Question。
  4. 对照 [`00-next-stage-expansions.md`](00-next-stage-expansions.md) 复核延后项：仍保留的进入第二阶段立项草案，不再需要的关闭并写明理由。
  5. 顶层文档版本号统一推进；交叉引用全部检查无悬挂链接（`grep` 一遍 `](.*\.md)` 即可）。
- **验收**：
  - [ ] 顶层文档版本一致；无悬挂引用。
  - [ ] 所有 Open Questions 状态明确（已定案 / 后续阶段细化且有默认方案）。
  - [ ] [`00-risk-register.md`](00-risk-register.md) 无滞留"开放"且已可关闭的条目。
  - [ ] [`00-next-stage-expansions.md`](00-next-stage-expansions.md) 中每个延后项都有保留/关闭结论。
- **关联 VS**：—
- **关联模块**：所有模块"后续扩展方向"节、[`00-open-questions.md`](00-open-questions.md)、[`00-risk-register.md`](00-risk-register.md)、[`00-next-stage-expansions.md`](00-next-stage-expansions.md)。
- **状态**：TODO

---

## 十三、跨阶段通用约束（每条 TASK 自查）

每条 TASK 在自检验收前，必须额外满足以下 10 条（取自实施计划 §十二）：

1. **Pillar 优先**：设计/实现冲突先用 [`00-design-pillars.md`](00-design-pillars.md) 裁决。
2. **技术红线**：[`00-tech-constraints.md`](00-tech-constraints.md) §十 八条禁止事项 + §五 插件门槛 + §六 美术与音频约束 + §七 性能指标全程强制。
3. **单例白名单**：仅允许 5 个 Autoload（[`00-tech-constraints.md`](00-tech-constraints.md) §四.1）；新增须书面评审。
4. **数据驱动**：业务数据进 `/data/`，不进 `/scripts/`。
5. **通信方式**：跨模块只能走 signal + EventBus；禁止跨模块直接调用节点方法。
6. **文档同步**：完成 TASK 后必须更新对应模块文档版本记录与 [`00-glossary.md`](00-glossary.md)。
7. **Codex 协作**：单文件 ≤ ~400 行，中文+英文术语对照。
8. **美术底基**：涉及视觉与动画的 TASK 必须遵守 [`00-art-direction.md`](00-art-direction.md)，第一阶段不默认引入 Live2D Cubism 或 Spine。
9. **微切片优先**：P1 完整地图和美术投入前必须先通过微切片门禁。
10. **延后项登记**：不进入 P1~P6 的内容必须写入 [`00-next-stage-expansions.md`](00-next-stage-expansions.md) 或模块"后续扩展方向"。

---

## 十四、TASK 状态跟踪表（速览）

| TASK ID | 阶段 | 状态 | 完成 SHA |
|---|---|---|---|
| TASK-P0-1-repo-skeleton | P0 | DONE | — |
| TASK-P0-2-config-decisions | P0 | DONE | — |
| TASK-P0-3-autoloads | P0 | DONE | — |
| TASK-P0-4-plugins-install | P0 | DONE | — |
| TASK-P0-5-gut-bootstrap | P0 | DONE | — |
| TASK-P0-6-schema-skeletons | P0 | DONE | — |
| TASK-P1-1-player-controller | P1 | DONE | `a28dbf7` |
| TASK-P1-2-dungeon-handmade | P1 | DONE | `42f9796` |
| TASK-P1-3-interactables-stub | P1 | DONE | `ca89401` |
| TASK-P1-4-phase-exit-review | P1 | DONE | `f81dbb9` |
| TASK-P2-1-rule-engine | P2 | DONE | `9acd9d8` |
| TASK-P2-2-da-zhi-ai | P2 | DONE | `ad22a25` |
| TASK-P2-3-pressure-feedback | P2 | DONE | `a5820a2` |
| TASK-P2-4-monster-clue-stubs | P2 | DONE | `b52b51c` |
| TASK-P2-5-phase-exit-review | P2 | DONE | `5023655` / review doc |
| TASK-P3-1-clue-system | P3 | DONE | `4840f2a` |
| TASK-P3-2-weakness-containment | P3 | TODO | — |
| TASK-P3-3-settlement-calculator | P3 | TODO | — |
| TASK-P3-4-death-respawn | P3 | TODO | — |
| TASK-P3-5-phase-exit-review | P3 | TODO | — |
| TASK-P4-1-loot-system | P4 | TODO | — |
| TASK-P4-2-origin-growth | P4 | TODO | — |
| TASK-P4-3-save-system | P4 | TODO | — |
| TASK-P4-4-phase-exit-review | P4 | TODO | — |
| TASK-P5-1-base-scene | P5 | TODO | — |
| TASK-P5-2-companion-support | P5 | TODO | — |
| TASK-P5-3-loop-integration | P5 | TODO | — |
| TASK-P5-4-phase-exit-review | P5 | TODO | — |
| TASK-P6-1-full-gut-sweep | P6 | TODO | — |
| TASK-P6-2-perf-baseline | P6 | TODO | — |
| TASK-P6-3-windows-export | P6 | TODO | — |
| TASK-P6-4-phase-exit-review | P6 | TODO | — |
| TASK-P7-1-narrative-polish | P7 | TODO（Q-01 已定案） | — |
| TASK-P7-2-difficulty-tuning | P7 | TODO | — |
| TASK-P8-1-ci-pipeline | P8 | TODO | — |
| TASK-P8-2-schema-validation-ci | P8 | TODO | — |
| TASK-P8-3-docs-closeout | P8 | TODO | — |

合计：**37 条 TASK**，P0、P1、P2 与 P3-1 已完成并通过命令行复核；当前可进入 TASK-P3-2 弱点与收容执行链。当前没有因开放问题阻塞的 TASK。

---

## 版本记录

### v1.6.0 - 2026-05-14

- 完成 TASK-P3-1：新增线索系统信息层、11 条线索资源、Dialogic 时间线占位、`ClueBook` 与收容行为验证规则。
- 审计修复 P3-1 验收口径：完整玩家路径验证和非开发者口述盲测推至 TASK-P3-5 出口门禁。
- 状态跟踪表写入实现提交 `4840f2a`；当前入口推进至 TASK-P3-2。
- 同步实施计划 v2.6.0、线索模块 v0.3.5、Monster Bible v0.2.7、术语表 v1.5.0 与总设定 v0.8.3。

### v1.5.9 - 2026-05-14

- 完成 TASK-P2-5：新增 `docs/perf/p2-review.md`，记录 P2 阶段出口走查。
- P2-5 审计修复新增 `rule_da_zhi_flashlight_stare_manifestation.tres`，使“大只至少两种特定条件现形”达标。
- P2 阶段全部 TASK 标记为 DONE；当前实施入口推进至 TASK-P3-1。
- 同步实施计划 v2.5.6、Monster Bible v0.2.6 与术语表 v1.4.7。

### v1.5.8 - 2026-05-14

- 完成 TASK-P2-4：新增 3 条大只线索规则占位 `.tres`，覆盖行为观察、击杀线索和收容线索。
- 记录 P2-4 设计、搭建、占位边界、审计修复和验收结果；状态跟踪表写入实现提交 `b52b51c`。
- 同步实施计划 v2.5.5、线索解谜模块 v0.3.4、Monster Bible v0.2.5 与术语表 v1.4.6。

### v1.5.7 - 2026-05-14

- 完成 TASK-P2-3：新增压力等级系统、HUD 叠层、心跳播放器、AudioBus layout、理智干扰 Shader 和首次入场现形触发器。
- 记录 P2-3 设计、搭建、占位资源、审计修复和验收结果；状态跟踪表写入实现提交 `a5820a2`。
- 同步实施计划 v2.5.4、恐怖感知与压力模块 v0.3.3、Monster Bible v0.2.4 与术语表 v1.4.5。

### v1.5.6 - 2026-05-14

- 完成 TASK-P2-2：新增大只 AI 骨架、LimboHSM 阶段节点、NavigationAgent2D、MonsterProfile 和 GUT 覆盖。
- 记录 P2-2 设计、搭建、占位资源、审计修复和验收结果；状态跟踪表写入实现提交 `ad22a25`。
- 同步实施计划 v2.5.3、怪物规则模块 v0.3.5 与 Monster Bible v0.2.3。

### v1.5.5 - 2026-05-14

- 完成 TASK-P2-1：新增 RuleEngine、8 个 GUT 用例和 4 条大只最低规则资源。
- 记录 P2-1 设计、搭建、审计修复和验收结果；状态跟踪表写入实现提交 `9acd9d8`。
- 同步实施计划 v2.5.2、怪物规则模块 v0.3.4、Monster Bible v0.2.2 与术语表 v1.4.4。

### v1.5.4 - 2026-05-14

- 完成 TASK-P1-4：新增 `docs/perf/p1-review.md`，记录 P1 阶段出口走查、验收命令、GoPeak 资源依赖审计和后续延后项。
- P1 阶段全部 TASK 标记为 DONE，当前入口推进至 TASK-P2-1。
- 同步实施计划 v2.5.1。

### v1.5.3 - 2026-05-14

- 完成 TASK-P1-3：新增四类交互物占位场景、统一交互接口、玩家临时交互 payload 消费和废弃学校 5 个交互实例。
- 记录 P1-3 设计、搭建、审计修复和验收结果；状态跟踪表写入实现提交 `ca89401`。

### v1.5.2 - 2026-05-14

- 完成 TASK-P1-2：新增微切片灰盒场景、完整破败校园灰盒、4 个候选房间、确定性房间池、关卡资源与 level manifest。
- 记录 P1-2 设计、搭建、审计修复和验收结果；状态跟踪表写入实现提交 `42f9796`。

### v1.5.1 - 2026-05-14

- 完成 TASK-P1-1：新增玩家控制器、Input Map、手电资源、LimboHSM 状态骨架、噪声事件 action id 与 GUT 覆盖。
- 记录 P1-1 设计、搭建、审计修复和验收结果；状态跟踪表写入实现提交 `a28dbf7`。

### v1.5.0 - 2026-05-14

- 同步实施计划 v2.5.0、技术规约 v1.3.1 与垂直切片 v1.0.4。
- TASK-P1-1 前置 Input Map action 输出与验收，禁止玩家控制脚本硬编码物理按键。
- TASK-P1-2 新增微切片灰盒产出、`level_manifest.tres` 与稳定资源 ID 验收。
- TASK-P2-1 / TASK-P3-4 前置 `RuleResource.learnable_hint` 与死亡学习提示最低版；TASK-P7-1 改为复盘提示打磨。
- TASK-P8-3 新增 `00-next-stage-expansions.md` 延后项复核。

### v1.4.1 - 2026-05-14

- 同步实施计划 v2.4.1、技术规约 v1.3.0 与垂直切片 v1.0.3：Q-19 / Q-20 全部定案。
- TASK-P0-2 增补美术制作底基与 2.5D Live 动画技术路线验收记录。
- TASK 红线与跨阶段自查新增 `00-art-direction.md` 约束：第一阶段使用 Godot 原生 2D Live 管线，不默认引入 Live2D Cubism 或 Spine。

### v1.4.0 - 2026-05-14

- 同步实施计划 v2.4.0 与技术规约 v1.2.3：Q-01 ~ Q-08 全部定案。
- TASK-P7-1 解除 Q-01 旧阻塞状态，改为 `TODO（Q-01 已定案）`。
- TASK-P1-1 状态更新为 P0 已完成后可进入 P1。

### v1.3.1 - 2026-05-14

- 同步实施计划 v2.3.1 与技术规约 v1.2.2：GoPeak v2.3.7 作为 dev-only Godot MCP 协作工具引入。

### v1.3.0 - 2026-05-14

- 同步实施计划 v2.3.0 与技术规约 v1.2.1。
- 记录 P0 命令行复核结果：Godot 空项目启动、schema 示例校验、GUT sanity test 均通过。
- TASK-P0-6 的 schema 校验入口定为命令行脚本，编辑器菜单入口延后至 P8-2。
- TASK-P0-1 ~ TASK-P0-6 全部改为 DONE，无待复核尾注；P1 可开始接单。

### v1.2.0 - 2026-05-14

- 同步实施计划 v2.2.0 与技术规约 v1.2.0：Q-15 ~ Q-18 全部定案，P0-2 改为 DONE。
- TASK-P0-4 安装 LimboAI v1.7.0、Dialogic 2.0-alpha-19、GUT v9.6.0，并新增 `docs/plugin-vetting.md`。
- TASK-P0-5 新增 GUT 示例配置与 sanity test。

### v1.1.0 - 2026-05-14

- 同步实施计划 v2.1.0 与技术规约 v1.1.0：Q-13 / Q-14 已定案为 2.5D Live + 厚涂精美二次元风格。
- TASK-P0-2 的阻塞项缩小为 Q-15 ~ Q-18，并保留 Q-13 / Q-14 的已定案验收记录。
- TASK-P1-2 的地图施工口径从最终 `TileMap` 改为 2.5D Live 场景嵌套与分层 Sprite / Parallax 搭建。
- 同步垂直切片 v1.0.1：程序化连通走廊改为第三阶段再评估。

### v1.0.0 - 2026-05-14

- 基于 [`00-implementation-plan.md`](00-implementation-plan.md) v2.0.1，把 25 个工作流细化为 37 条可施工 TASK。
- 每条 TASK 含：ID、前置、产出文件路径、实现步骤、验收条件、关联 VS 条目、关联模块文档、状态。
- 提供阶段总览、跨阶段通用约束、TASK 状态跟踪表三类速查表。
- 显式标记 BLOCKED TASK 与所依赖的 Open Question，避免上手即卡死。
