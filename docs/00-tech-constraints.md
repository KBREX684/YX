# 技术选型与底基约束 Tech Constraints

版本：v1.3.0
关联总设定版本：v0.8.1
创建日期：2026-05-14
最后更新：2026-05-14

## 用途

本文档是 YX 项目的**技术最高规约**，与 `docs/00-design-pillars.md` 并列，分别从设计与工程两侧约束所有模块实现。

- 设计层：所有玩法决策须通过 [Design Pillars](00-design-pillars.md) 裁决。
- 视觉层：所有美术、动画和外包资产须通过 [Art Direction](00-art-direction.md) 裁决。
- 工程层：所有技术决策须通过本文档裁决。

适用范围：第一阶段原型（垂直切片，详见 [docs/00-vertical-slice.md](00-vertical-slice.md)）。第二阶段开始前需复盘并按需升版本。

面向场景：YX —— 2.5D 恐怖躲藏探索 + 无限流异常副本 + 怪物原形养成；开发模式：**一人独立 + Codex 协助，低代码 / 无代码优先**。

---

## 一、总体原则（一切技术决策的上位约束）

1. **支柱优先（Pillar First）**：所有技术选项必须服务两条 Design Pillar，禁止为炫技牺牲"看不见但可学习的怪物"与"变强=变危险"的可表达性。
2. **单人可维护（Solo Maintainable）**：任何引入的工具/库/服务，若 1 人无法在 2 天内学会基本用法，原则上不引入。
3. **低代码优先（Low-Code First）**：能用编辑器面板（Inspector / Resource / 可视化图节点）解决的，不写脚本；能写脚本解决的，不写引擎扩展；能用 GDScript 解决的，不引入 C#/C++。
4. **数据驱动（Data-Driven）**：怪物、规则、地图、原形、副本主题、声音事件等内容，全部以 **资源文件（.tres / JSON / CSV）** 表达，禁止硬编码业务数据到代码逻辑中。
5. **Codex 友好（AI-Friendly）**：模块边界清晰、命名一致、单文件不超过 ~400 行、注释采用统一中文+英文术语对照，方便 AI 阅读与生成。
6. **垂直切片优先（Vertical Slice First）**：技术栈以能尽快完成 `docs/00-vertical-slice.md` 的 P0 清单为唯一阶段性目标，不为未来"可能需要的多人/移动端"提前预留架构。

---

## 二、核心引擎与版本

| 项目 | 选型 | 备注 |
|---|---|---|
| 游戏引擎 | **Godot 4.6.2 stable** | winget 安装版本；开源；2.5D/2D 支持优秀；GDScript 适合低代码 |
| 渲染后端 | **Forward+（桌面端）** | 支持现代光照与雾效，营造恐怖氛围 |
| 主脚本语言 | **GDScript** | 一人开发首选，Codex 生成质量足够；强类型语法（`var x: int`）必写 |
| 辅助语言 | 不自写 C#/C++/Rust 业务代码；第三方插件自带 GDExtension 必须通过插件采纳门槛 | 降低工具链复杂度，同时允许 LimboAI 这类已核查插件 |
| 目标平台（第一阶段） | **Windows 64-bit 桌面，单机离线** | 不做 Web / Mobile / 主机；不做联机 |
| 最低硬件目标 | 1080p / 60fps / GTX 1060 等级 | 2.5D 项目应轻松达成 |

---

## 三、项目结构与目录约束

```
/project.godot
/addons/             # 第三方插件，每个插件独立目录
/assets/             # 美术与音频原始资源（按类型再分子目录）
  /sprites/  /audio/  /fonts/  /shaders/
/data/               # 数据资源（.tres / .json）：怪物、原形、规则、道具表
  /monsters/  /origins/  /rules/  /items/  /levels/
/scenes/             # 场景文件 .tscn，按模块组织
  /player/  /monster/  /dungeon/  /base/  /ui/
/scripts/            # GDScript，与 scenes 目录一一对应
  /player/  /monster/  /systems/  /ui/  /autoload/
/tests/              # GUT 单元测试
/docs/               # 设计文档（已有）
/tools/              # 编辑器扩展脚本（@tool）
```

- 一个场景 = 一个目录 = 一个根脚本，命名同名（`player.tscn` + `player.gd`）。
- 业务数据**禁止**进 `scripts/`，必须进 `data/`。

---

## 四、架构与模式约束

1. **Autoload（单例）白名单**（避免单例膨胀）：
   - `GameState`（全局游戏状态、副本/基地切换）
   - `EventBus`（信号总线，跨模块通信）
   - `SaveSystem`（存档）
   - `AudioManager`（音频）
   - `Config`（运行时配置读取）
   - 其余一律走信号或资源传参。
   - Dialogic 2 已安装到 `/addons/`，但 P0 默认不启用其 editor plugin；该插件启用时会自动注册 Dialogic 运行时 Autoload。后续剧情/线索任务若必须启用，需在对应 TASK 中更新本节白名单并重新验证空项目无红字。
   - GoPeak MCP runtime addon 已安装但默认不启用；启用会引入运行态桥接能力，必须作为开发工具单独记录，禁止成为正式游戏运行依赖。
2. **通信方式**：模块间通信 **统一使用 Godot 信号（signal）+ EventBus**，禁止跨模块直接调用其他节点的方法。
3. **怪物 AI**：第一阶段使用 **LimboAI v1.7.0** 实现 Behavior Tree + 状态机工作流；必要时可配合 Godot 内置 `AnimationTree` 做动画状态。禁止在单文件里写超过 3 层的 if/else 行为逻辑。
4. **怪物异常规则**：每条规则一个 `RuleResource (.tres)`，包含触发条件、效果、可学习线索字段。规则由 `RuleEngine` 统一评估，**不**写死在怪物脚本里。
5. **地图**：第一阶段为手工关卡，使用场景嵌套 + `Node2D` / `Sprite2D` / `Parallax2D` / `CollisionShape2D` / `NavigationRegion2D` 组织 2.5D Live 场景。`TileMap` 仅允许作为灰盒/blockout 或碰撞参考，不作为最终画面瓦片方案。
6. **存档**：使用 Godot `ResourceSaver` 保存自定义 Resource，或 JSON。**禁止**使用 Pickle/二进制不可读格式（一人调试需要可读性）。

---

## 五、低代码 / 无代码工具链

| 用途 | 工具 | 理由 |
|---|---|---|
| 对话/剧情 | **Dialogic 2**（Godot 插件） | 节点式编辑器，零脚本可做线索/笔记/对话；P0 仅安装入库，默认不启用，剧情任务按需接入 |
| 行为树 / 状态机 | **LimboAI v1.7.0** | Q-16 已定案；Behavior Tree + 状态机融合，可视化怪物 AI 编辑 |
| 关卡 | Godot 场景嵌套 + Node2D / Parallax2D / Sprite2D / Collision / Navigation | 适配 2.5D Live 厚涂场景；`TileMap` 仅作灰盒辅助 |
| 美术源文件 | Krita / Clip Studio Paint / Photoshop；默认免费底基推荐 Krita | 工具只负责分层绘制；正式运行资源以 PNG / `.tscn` / `.tres` 为准 |
| 2.5D Live 动画 | Godot `AnimationPlayer` + `Skeleton2D` / `Bone2D` / `Polygon2D` + `Sprite2D` / Shader | 第一阶段全部动画必须能在 Godot 编辑器内预览和维护 |
| 视觉脚本 | **不使用 VisualScript**（Godot 4 已移除），改用 **资源驱动+短 GDScript** | 兼顾低代码与可维护 |
| 调试 | Godot 内建 Debugger + `print_rich` | 不引入额外工具 |
| 数据表编辑 | `.tres` 用 Godot Inspector；大批量表用 CSV，运行时导入 | Codex 生成 CSV/JSON 比生成代码更稳 |
| AI 协作 | **Codex / Copilot**，要求生成代码遵守本文规约 | 与现有 Codex 工作流匹配 |
| Godot MCP 协作 | **GoPeak v2.3.7**（开发工具） | 仅用于 Codex 编辑/运行/检查 Godot 项目；默认启用 editor bridge，不启用 runtime addon |

**插件采纳门槛**：正式游戏功能插件必须 MIT/MPL/Apache 类宽松许可，GitHub star ≥ 500，最近 6 个月有更新；不满足任一项则不引入。开发期 MCP / 编辑器桥接工具可作为例外引入，但必须标注为 dev-only，记录在 `docs/plugin-vetting.md`，并保证不成为正式游戏运行依赖。

---

## 六、美术与音频技术约束

1. **风格**：2.5D Live 表现 + 厚涂精美二次元风格，固定镜头（已在概念文档 v0.8.1 与 [`00-art-direction.md`](00-art-direction.md) v1.0.0 确认）。美术风格服务"看不清但能感到危险"的恐怖叙事，强调体积、光影、材质、角色魅力和异常变形；不使用像素风或低多边形手绘作为主风格。
2. **分辨率基准**：1080p 内部渲染，UI 9-slice，禁止使用未压缩 4K 贴图。
3. **2.5D Live 资产**：角色 / 拟人原形 / 怪物现形使用高分辨率分层透明图，优先以 `Sprite2D`、`AnimationPlayer`、`Skeleton2D` / `Bone2D` / `Polygon2D`、网格变形和 Shader 做呼吸、凝视、衣摆、阴影和异常扰动等细微动态。场景按前景 / 中景 / 背景 / 遮挡层 / 光影层拆分，使用 `Parallax2D` 和固定镜头构建纵深。禁止把 32×32 / 64×64 像素瓦片作为全局资产基准。
4. **外部动画运行时边界**：第一阶段不以 Live2D Cubism 或 Spine 作为底基。Live2D 官方 SDK 平台不直接包含 Godot，Godot 接入通常依赖非官方扩展或原生适配；Spine 虽有官方 Godot runtime，但会引入额外授权与导入流程。两者仅可在第二阶段后按插件采纳门槛重新评估。
5. **音频**：
   - 格式：BGM 用 `.ogg`，音效用 `.wav`。
   - **3D 空间化音频强制启用**（`AudioStreamPlayer2D` + Attenuation），因为"听声辨怪"是核心机制。
   - 心跳、手电闪烁、环境异响使用 **AudioBus** 分组，便于动态混音。
6. **素材来源**：第一阶段允许使用 CC0 / 已购素材包 / 灰盒块面占位（itch.io、Kenney、Freesound 等），但最终美术目标必须回到 2.5D Live + 厚涂精美二次元风格；自有美术在垂直切片核心循环验收后再集中投入。

---

## 七、性能与质量约束

| 指标 | 目标 |
|---|---|
| 帧率 | 副本场景 60fps 稳定，基地 60fps |
| 单帧脚本耗时预算 | < 4ms（剩余给渲染/物理） |
| 单场景节点数 | < 2000 |
| 一次副本加载时间 | < 5s |
| 存档大小 | < 5MB |
| 内存占用 | < 1.5GB |

测量工具：Godot Profiler、Monitor，垂直切片完成时必须出一份性能基线报告。

---

## 八、版本管理与协作

1. **Git**：单分支 `main` + 功能分支 `feature/*`；一人开发不强制 PR，但提交需 Conventional Commits（`feat:` / `fix:` / `docs:` / `chore:`）。
2. **大文件**：Godot 的 `.import` 缓存与 `.tmp` 进 `.gitignore`；超过 10MB 的二进制资源（音频/视频）启用 **Git LFS**。
3. **CI（可选，后期）**：GitHub Actions 跑 Godot headless 导出 + GUT 测试；垂直切片阶段可不引入。
4. **文档同步**：每次新增系统必须更新 `docs/modules/` 对应模块文件与 `docs/00-glossary.md`，并按 `game-concept.md` 版本规则递增。

---

## 九、测试约束（轻量化）

- 单元测试框架：**GUT（Godot Unit Test）**，**仅强制覆盖**：
  - `RuleEngine`（异常规则触发判定）
  - `SaveSystem`（存档读写）
  - `SettlementCalculator`（错误收容惩罚计算）
- 其余系统以**手动验收清单**（即 `00-vertical-slice.md`）替代单元测试。
- 不引入 E2E / 截图回归测试（一人维护成本过高）。

---

## 十、禁止事项（明确划线）

为防止后期失控，第一阶段明确禁止：

1. ❌ 联网 / 多人 / 排行榜 / 云存档
2. ❌ 内购 / 广告 / 第三方账号系统
3. ❌ 程序化大地图生成（已确认手工关卡）
4. ❌ 引入第二种编程语言（C#/C++/Python 脚本）
5. ❌ 自研编辑器或自研 ECS 框架
6. ❌ 引入 Unity/Unreal/Cocos 任何资源/工作流
7. ❌ 使用 AI 实时生成游戏内文本/图像（异常规则必须人工可控）
8. ❌ 任何未在本文 §五 列表中的第三方插件，未经评审不得加入；dev-only 工具必须单独标注，不得伪装为正式玩法依赖

---

## 十一、风险与回退预案

对应 [docs/00-risk-register.md](00-risk-register.md)。

| 风险 | 触发条件 | 回退方案 |
|---|---|---|
| GDScript 性能不足 | 单帧脚本耗时 > 8ms 持续 | 仅将瓶颈热点改写为 GDExtension（C++），不全栈迁移 |
| LimboAI/Dialogic 停更或破坏更新 | 升级 Godot 后插件不可用 | 锁定插件版本至 `addons/`；必要时自研最小行为树（仅状态切换） |
| 一人产能不足 | 垂直切片进度滞后 > 1 个月 | 削减副本主题为 1 个房间、怪物为 1 只、原形为 1 个，保留核心循环验证 |
| 美术资源积压 | 自制美术拖延 | 全程使用占位素材直到核心循环验收通过 |

---

## 十二、交付物定义（垂直切片范围）

一个 Windows `.exe` 单文件包，运行后能完成 [docs/00-vertical-slice.md](00-vertical-slice.md) 所列 P0 项，且：

- 启动到主菜单 ≤ 3 秒
- 副本→基地→副本一次完整循环 ≤ 10 分钟
- 无崩溃、无脚本红字报错
- 存档可重启游戏后正确恢复

---

## 十三、已定案技术开放项

下列条目已同步至 [docs/00-open-questions.md](00-open-questions.md)（Q-13 ~ Q-20），当前均已定案：

1. 已定案：2.5D Live 分层资产规格，不使用 32×32 / 64×64 像素瓦片路线。（Q-13）
2. 已定案：厚涂精美二次元风格，不使用像素风或低多边形手绘作为主风格。（Q-14）
3. 已定案：第一阶段固定使用 **GDScript**，不引入 C#。（Q-15）
4. 已定案：行为树 / 状态机插件选用 **LimboAI v1.7.0**。（Q-16）
5. 已定案：第一阶段不引入 Steam SDK（成就 / 云存档 / 排行榜等均不做）。（Q-17）
6. 已定案：第一阶段仅中文，目标语言 `zh_CN`。（Q-18）
7. 已定案：美术源文件采用 Krita / Clip Studio Paint / Photoshop 均可，默认免费底基推荐 Krita；正式运行资源以分层 PNG / `.tscn` / `.tres` 为准。（Q-19）
8. 已定案：第一阶段 2.5D Live 动画采用 Godot 原生管线，不使用 Live2D Cubism 或 Spine 作为底基。（Q-20）

---

## 版本记录

### v1.3.0 - 2026-05-14

- 同步 `game-concept.md` v0.8.1 与 `00-art-direction.md` v1.0.0。
- 将美术源文件、2.5D Live 动画与外部动画运行时边界写入低代码工具链和美术技术约束。
- 明确第一阶段使用 Godot 原生 2D Live 管线；Live2D Cubism 与 Spine 不作为第一阶段底基，仅第二阶段后评估。
- 同步 `00-open-questions.md` v1.5.0：新增 Q-19 美术制作底基、Q-20 2.5D Live 动画技术路线。

### v1.2.3 - 2026-05-14

- 同步 `game-concept.md` v0.8.0 与 `00-open-questions.md` v1.4.0：当前无用户待确认阻塞项。
- §十三标题改为“已定案技术开放项”，避免与已关闭的叙事/内容问题口径冲突。

### v1.2.2 - 2026-05-14

- 增补 GoPeak v2.3.7 为 dev-only Godot MCP 协作工具：默认启用 editor bridge，不启用 runtime addon。
- 调整插件采纳门槛表述：正式游戏功能插件继续执行 stars ≥ 500 等门槛；开发期 MCP / 编辑器桥接工具允许例外，但必须记录且不得成为正式运行依赖。

### v1.2.1 - 2026-05-14

- P0 命令行复核后补充 Dialogic 运行时边界：插件已安装入库，但默认不启用 editor plugin，避免自动注册 Dialogic Autoload 影响启动验收。
- Autoload 白名单维持 5 项；若后续剧情任务确需 Dialogic Runtime，必须在对应任务中书面更新白名单并重新验证。

### v1.2.0 - 2026-05-14

- 同步 `00-open-questions.md` v1.3.0：Q-15 ~ Q-18 全部定案。
- 怪物 AI 工具链固定为 LimboAI v1.7.0；主脚本语言固定为 GDScript。
- 明确第一阶段不接入 Steam SDK，仅支持中文本地化。
- 固定本机引擎版本为 Godot 4.6.2 stable，并澄清第三方 GDExtension 插件与"不自写第二语言"的边界。

### v1.1.0 - 2026-05-14

- 同步 `game-concept.md` v0.7.0：美术方向定案为 2.5D Live + 厚涂精美二次元风格。
- 地图与关卡技术约束从最终 `TileMap` 瓦片路线调整为场景嵌套 + 分层 Sprite / Parallax / Collision / Navigation；`TileMap` 仅保留为灰盒辅助。
- Q-13 / Q-14 从待决项改为已定案项，Q-15 ~ Q-18 继续保留为待用户决策。

### v1.0.0 - 2026-05-14

- 建立技术选型与底基约束文档。
- 确认引擎：Godot 4.x + GDScript + Windows 64-bit 桌面单机。
- 明确目录结构、Autoload 白名单、数据驱动与低代码工具链。
- 列出 8 条禁止事项与 4 条风险回退预案。
- 同步 6 条待决策开放项至 `docs/00-open-questions.md`（Q-13 ~ Q-18）。
