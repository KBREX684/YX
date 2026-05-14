# 项目实施计划 Implementation Plan

版本：v2.5.4
关联总设定版本：v0.8.2
关联技术规约版本：[`00-tech-constraints.md`](00-tech-constraints.md) v1.3.1
关联垂直切片版本：[`00-vertical-slice.md`](00-vertical-slice.md) v1.0.4
创建日期：2026-05-14
最后更新：2026-05-14

---

## 一、用途

本文档是 YX 项目的**工程实施纲领**，与设计层的 [`00-design-pillars.md`](00-design-pillars.md) 和工程层的 [`00-tech-constraints.md`](00-tech-constraints.md) 配套：

- Design Pillars 决定"做什么是合理的"。
- Tech Constraints 决定"用什么技术做是合理的"。
- **本文档决定"按什么次序、按什么粒度推进，才能把上面两者落到 [`00-vertical-slice.md`](00-vertical-slice.md) 验收单上"。**

本文档**不规定具体日历时间**（一人独立开发 + Codex 协助，时间预算不稳定且易诱发范围蔓延）。一切排程以"上一阶段验收门禁通过"为唯一前置条件。

> **阶段编号与 [`00-vertical-slice.md`](00-vertical-slice.md) 的 P0/P1 标签相互独立**。本文档的 P0~P8 是实施里程碑，垂直切片文档的 P0/P1 是验收清单的优先级分类——两套体系不混用。

### 阶段总览

| 阶段 | 名称 | 核心交付物 | 对应垂直切片节 |
|---|---|---|---|
| **P0** | 工程底座与配置决策 | 空项目可运行 + 工具链确认 | — |
| **P1** | 地图与玩家原型 | 玩家能在完整副本中移动探索（无怪物） | VS §1 §3 部分 |
| **P2** | 怪物系统与感知压力 | 大只可追杀玩家，压力反馈正常驱动 | VS §2 §4 |
| **P3** | 线索、解谜与结算 | 三条路径均可通关并触发对应结算 | VS §5 §6 |
| **P4** | 搜刮深度与原形养成 | 资源循环成立，原形三路线可投喂至锁定 | VS §7 §8 |
| **P5** | 原形助战与核心循环 | 带原形完整循环：基地→副本→结算→基地 | VS §9 §10 §11 |
| **P6** | 垂直切片验收与性能基线 | 所有 VS P0 项全勾 + Windows .exe 交付 | VS 全部 P0 |
| **P7** | 体验打磨与氛围补完 | VS P1 四条全勾 + 难度曲线收敛 | VS P1 |
| **P8** | 工程化与发布管线 | CI 绿 + 可重复发布 + 文档收尾 | — |

> 本文档明确**不**涉及第二阶段（更多副本主题、研究树、第二只怪、程序化走廊、多结局等），上述项集中登记在 [`00-next-stage-expansions.md`](00-next-stage-expansions.md)，并于 P8 验收后另行立项。

---

## 二、参考文档总览

下列文档共同构成本计划的"上位输入"，每个工作流都必须在其"关联文档"字段中显式回链至少一篇。

### 顶层约束

| 文档 | 角色 |
|---|---|
| [`docs/game-concept.md`](game-concept.md) | 总设定与核心循环来源 |
| [`docs/00-design-pillars.md`](00-design-pillars.md) | 设计裁决（Pillar 1 / Pillar 2） |
| [`docs/00-art-direction.md`](00-art-direction.md) | 美术与动画制作底基（2.5D Live / 厚涂精美二次元 / Godot 原生动画管线） |
| [`docs/00-tech-constraints.md`](00-tech-constraints.md) | 技术裁决（引擎、目录、Autoload、低代码工具链、禁止事项） |
| [`docs/00-vertical-slice.md`](00-vertical-slice.md) | 垂直切片唯一验收单（文档内的"P0/P1"是验收优先级标签，与本计划的 P0~P8 实施里程碑是独立体系，不混用） |
| [`docs/00-glossary.md`](00-glossary.md) | 术语统一来源 |
| [`docs/00-risk-register.md`](00-risk-register.md) | 风险跟踪（R-XX 编号） |
| [`docs/00-open-questions.md`](00-open-questions.md) | 设计决策与开放问题登记（Q-XX 编号） |
| [`docs/00-next-stage-expansions.md`](00-next-stage-expansions.md) | 下一阶段扩展项、延后原因与回归条件 |

### 模块文档

| # | 模块 | 文档 |
|---|---|---|
| 01 | 玩家控制与探索 | [`modules/01-player-control-exploration.md`](modules/01-player-control-exploration.md) |
| 02 | 副本生成与地图 | [`modules/02-dungeon-generation-map.md`](modules/02-dungeon-generation-map.md) |
| 03 | 怪物与异常规则 | [`modules/03-monster-anomaly-rules.md`](modules/03-monster-anomaly-rules.md) |
| 04 | 恐怖感知与压力 | [`modules/04-horror-perception-pressure.md`](modules/04-horror-perception-pressure.md) |
| 05 | 线索、解谜与规则推理 | [`modules/05-clues-puzzles-rule-deduction.md`](modules/05-clues-puzzles-rule-deduction.md) |
| 06 | 副本目标与结算 | [`modules/06-objectives-settlement.md`](modules/06-objectives-settlement.md) |
| 07 | 搜刮与资源 | [`modules/07-looting-resources.md`](modules/07-looting-resources.md) |
| 08 | 原形获取与养成 | [`modules/08-origin-acquisition-growth.md`](modules/08-origin-acquisition-growth.md) |
| 09 | 原形携带与助战 | [`modules/09-origin-companion-support.md`](modules/09-origin-companion-support.md) |
| 10 | 基地经营与研究 | [`modules/10-base-management-research.md`](modules/10-base-management-research.md) |
| 11 | 叙事与世界观 | [`modules/11-narrative-worldbuilding.md`](modules/11-narrative-worldbuilding.md) |
| 12 | 进度、难度与长期成长 | [`modules/12-progression-difficulty-longterm-growth.md`](modules/12-progression-difficulty-longterm-growth.md) |

### Monster Bible

| 怪物 | 文档 |
|---|---|
| 大只（Da Zhi） | [`monsters/001-da-zhi.md`](monsters/001-da-zhi.md) |

---

每个工作流统一字段如下：
- **目标**：本工作流要让什么验收项变为可勾选，或产出什么明确交付物。
- **主要工作**：粗粒度任务列表（不下沉到代码级）。
- **关联文档**：模块文档 + 必要的顶层文档。
- **关联 Pillar**：受哪条 Pillar 裁决（无强关联则标"—"）。
- **验收门禁**：本工作流可被宣告完成的条件（必须可勾选 / 可观察）。
- **关联风险**：会触发哪些 R-XX 风险，需重点观察。

---

## 三、P0 阶段：工程底座与配置决策

**阶段目标**：搭建完整项目骨架，决策所有技术配置项（Q-13~Q-20 已全部定案），使后续所有阶段可以在统一约定下逐步推进。本阶段**不实现任何游戏玩法**，只产出"空项目能运行、工具链确认可用、数据结构已预留接口"。

**当前状态（2026-05-14）**：P0 命令行门禁已通过。空项目可进入占位主菜单，运行时 Autoload 为 5 项白名单；schema 示例资源 4/4 通过；GUT sanity test 1/1 通过。

---

### P0-1 目录结构与版本管理

- **目标**：建立符合 [`00-tech-constraints.md`](00-tech-constraints.md) §三 约定的项目骨架，并配置好版本管理。
- **主要工作**：
  1. 按 Tech Constraints §三 建立 `/assets` `/data` `/scenes` `/scripts` `/tests` `/tools` 全部目录。
  2. 建立 `.gitignore`（含 `.import` / `.tmp`），评估并配置 Git LFS（音频/视频 > 10MB 时启用）。
  3. 在 README 中写入版本号规则，与 [`game-concept.md`](game-concept.md) 总版本号联动。
- **关联文档**：[`00-tech-constraints.md`](00-tech-constraints.md) §三、§八。
- **关联 Pillar**：—。
- **验收门禁**：Godot 项目文件存在，目录结构与 §三 图示完全吻合；`.gitignore` 覆盖全部 Godot 缓存文件。
- **关联风险**：目录约定不一致会导致后期 Codex 生成路径漂移。

---

### P0-2 配置决策（Q-13 ~ Q-20）

- **目标**：将 [`00-tech-constraints.md`](00-tech-constraints.md) §十三 与 [`00-open-questions.md`](00-open-questions.md) 中所有阻塞工程进行的开放项全部由用户拍板并回填。
- **主要工作**：
  1. Q-13：已定案为 2.5D Live 分层资产规格，不使用 32×32 / 64×64 像素瓦片路线。
  2. Q-14：已定案为厚涂精美二次元风格，不使用像素风或低多边形手绘作为主风格。
  3. Q-15：已定案为 GDScript，不引入 C#。
  4. Q-16：已定案为 LimboAI v1.7.0。
  5. Q-17：已定案为第一阶段不引入 Steam SDK。
  6. Q-18：已定案为第一阶段仅中文（`zh_CN`）。
  7. Q-19：已定案为 Krita / Clip Studio Paint / Photoshop 分层源文件 + PNG 导出；默认免费底基推荐 Krita。
  8. Q-20：已定案为 Godot 原生 2D Live 管线；Live2D Cubism 与 Spine 不作为第一阶段底基。
- **关联文档**：[`00-open-questions.md`](00-open-questions.md)（Q-13 ~ Q-20）、[`00-art-direction.md`](00-art-direction.md)、[`00-tech-constraints.md`](00-tech-constraints.md) §十三。
- **关联 Pillar**：—。
- **验收门禁**：以上八项均在 [`00-open-questions.md`](00-open-questions.md) 中标注"已定案"，决策内容回填至 [`00-art-direction.md`](00-art-direction.md) 与 [`00-tech-constraints.md`](00-tech-constraints.md) 对应位置。
- **关联风险**：任何一项未决将阻塞后续工程展开。

---

### P0-3 Autoload 五件套与插件安装

- **目标**：建立全项目共享的 5 个 Autoload 骨架，并装入所有受限插件。
- **主要工作**：
  1. 创建 `GameState` / `EventBus` / `SaveSystem` / `AudioManager` / `Config` 五个 Autoload，仅接口与空实现，相互无循环依赖。
  2. 按 P0-2 决策装入 LimboAI v1.7.0、Dialogic 2、GUT，逐项核对 [`00-tech-constraints.md`](00-tech-constraints.md) §五 插件采纳门槛（MIT 类许可 / star ≥ 500 / 最近 6 个月有更新）。P0 默认仅启用 GUT；Dialogic 已安装但不默认启用，避免自动注册额外运行时 Autoload。
  3. 引入 GUT，写一个示例测试用例确保框架可运行。
- **关联文档**：[`00-tech-constraints.md`](00-tech-constraints.md) §四.1、§五。
- **关联 Pillar**：—。
- **验收门禁**：五个 Autoload 在 `Project Settings` 中已注册，空项目无报错运行并显示占位主菜单；GUT 示例用例打印通过；插件采纳门槛核查表已归档。
- **关联风险**：[`00-risk-register.md`](00-risk-register.md) 插件停更风险；此时锁定插件版本至 `addons/`。

---

### P0-4 核心数据资源 Schema 预定义

- **目标**：建立 `RuleResource` / `OriginResource` / `MonsterProfile` / `ItemResource` 的 `.gd` 框架文件（仅字段定义，无业务逻辑），确保后续阶段数据格式一致。
- **主要工作**：
  1. 按 [`00-tech-constraints.md`](00-tech-constraints.md) §四.4 与各模块文档的"数据契约"节定义字段。
  2. 所有资源文件置于 `/data/` 对应子目录。
  3. 在 `/tools/` 写入命令行 schema 校验脚本，验证字段完整性并用退出码阻断错误数据。
- **关联文档**：[`modules/03-monster-anomaly-rules.md`](modules/03-monster-anomaly-rules.md)、[`modules/08-origin-acquisition-growth.md`](modules/08-origin-acquisition-growth.md)、[`modules/07-looting-resources.md`](modules/07-looting-resources.md)。
- **关联 Pillar**：—（Codex 友好原则，便于 AI 生成内容遵守格式）。
- **验收门禁**：四个核心资源类型均有对应 `.gd`，schema 校验脚本可在命令行运行并打印"通过"；无硬编码业务字段进 `/scripts/`。
- **关联风险**：Schema 漂移导致后期跨模块字段不一致。

---

## 四、P1 阶段：地图与玩家原型

**阶段目标**：在手工搭建的副本场景里，玩家能完整移动、探索、开门、拾取物品、阅读线索、使用手电。**本阶段没有怪物**，只验证"人在图中"基础可玩性与场景结构。

**当前状态（2026-05-14）**：P1 出口走查已通过，记录见 [`docs/perf/p1-review.md`](perf/p1-review.md)；P2 已启动，当前入口见 P2 当前状态。

**微切片门禁**：P1 不直接冲完整破败校园。先完成 [`00-vertical-slice.md`](00-vertical-slice.md) "微切片门禁"：Input Map + 玩家基础动词 + 走廊 + 2 个房间 + 1 个躲藏点 + 1 个交互占位物 + 1 次地图变化 + 1 条噪声事件。通过后再扩展到 4–6 房间版本和完整 P1 出口门禁。

---

### P1-1 玩家控制与探索

- **目标**：勾选 [`00-vertical-slice.md`](00-vertical-slice.md) §1 第 1 项和第 3 项（移动/蹲伏/开门/拾取/阅读/躲藏 + 手电电量反馈）；第 2 项（行为产生不同怪物判断结果）的噪声信号接口在本阶段实现，但需要怪物接入后才可观察验证，**第 2 项的验收推迟至 P2**；第 4 项死亡复活推迟至 P3-4。
- **主要工作**：
  1. 在 `project.godot` Input Map 中先定义 `move_left` / `move_right` / `move_up` / `move_down` / `run` / `crouch` / `flashlight` / `interact` / `hide` / `pause`，玩家脚本只读 action，不硬编码物理按键。
  2. 实现玩家 `CharacterBody2D`，状态机使用 P0-3 选定的插件，**禁止**单文件多层 if/else（[`00-tech-constraints.md`](00-tech-constraints.md) §四.3）。
  3. 行走/奔跑/蹲伏产生的"噪声等级"作为信号经 `EventBus` 广播（为 P2 怪物 AI 预留订阅口），信号中保留稳定 action id。
  4. 手电系统：电量资源化（`.tres`），电量阈值触发视觉反馈。
- **关联文档**：[`modules/01-player-control-exploration.md`](modules/01-player-control-exploration.md)。
- **关联 Pillar**：Pillar 1（行为差异须可被怪物"学习"，不是孤立手感）。
- **验收门禁**：Input Map action 全部存在；玩家可在微切片或副本内完成行走/奔跑/蹲伏/开门/拾取/阅读/进入躲藏点；手电开关有电量消耗，电量低时视觉反馈激活；控制脚本不硬编码物理按键。
- **关联风险**：手感与恐怖感平衡（详见 [`00-risk-register.md`](00-risk-register.md)）。

---

### P1-2 手工副本地图（破败校园）

- **目标**：勾选 [`00-vertical-slice.md`](00-vertical-slice.md) §3（地图分区 + 一次变化事件 + 三路径不阻断 + 重玩房间池）。
- **主要工作**：
  1. 先搭建灰盒微切片：主走廊 + 2 个房间 + 1 个躲藏点 + 1 个可交互占位物（stub）+ 1 次地图变化事件，确认路径不阻断后再扩展。
  2. 用场景嵌套 + `Node2D` / `Sprite2D` / `Parallax2D` / 碰撞层手工搭建 1 个 2.5D Live 副本：入口区 / 主走廊 / 4–6 候选房间 / 仪式房 / 出口区。`TileMap` 仅可作为灰盒辅助，最终画面不走瓦片方案；**禁止**程序化生成（[`00-tech-constraints.md`](00-tech-constraints.md) §十.3）。
  3. `NavigationRegion2D` 配置（为 P2 怪物寻路预留）。
  4. "变化事件"由 `RuleResource` 驱动（走廊变长 / 门牌错乱 / 已探索房间出现新物品三选一），数据驱动可切换，并拥有稳定 `resource_id`。
  5. 候选房间池使用确定性随机种子，便于复盘。
- **关联文档**：[`modules/02-dungeon-generation-map.md`](modules/02-dungeon-generation-map.md)、[`00-art-direction.md`](00-art-direction.md)。
- **关联 Pillar**：Pillar 1（地图变化须可解释、可学习）。
- **验收门禁**：微切片门禁先通过；随后 [`00-vertical-slice.md`](00-vertical-slice.md) §3 全部 4 项可勾选；从入口到任一路径出口步行 ≤ 90 秒。
- **关联风险**：[`00-risk-register.md`](00-risk-register.md) R-01（体验曲线塌陷，地图是动态危险度的承载位）。

---

## 五、P2 阶段：怪物系统与感知压力

**阶段目标**：大只进入副本，玩家能被追杀，压力反馈系统正确驱动。本阶段不要求玩家能"赢"（线索/结算尚未完成），只要求怪物行为可观察、可推理、反馈可区分强弱。

**当前状态（2026-05-14）**：P2-1 RuleEngine、P2-2 大只 AI 骨架与 P2-3 恐怖感知压力反馈已完成，当前可进入 P2-4 怪物线索占位规则池施工。

---

### P2-1 RuleEngine 与怪物异常规则

- **目标**：建立 `RuleEngine` 系统，大只的全部行为由数据规则驱动而非硬编码。
- **主要工作**：
  1. 实现 `RuleEngine`：消费 `RuleResource (.tres)` 列表，订阅 `EventBus`，输出触发结果与线索解锁状态。**禁止**将规则硬编码进怪物脚本（[`00-tech-constraints.md`](00-tech-constraints.md) §四.4）。
  2. 现形条件、弱点条件、收容三步仪式全部以 `RuleResource` 表达，对齐 [`monsters/001-da-zhi.md`](monsters/001-da-zhi.md)。
  3. 每条会导致死亡、失败或错误收容的规则必须填入 `learnable_hint`，用于 P3-4 的最低失败学习反馈。
  4. 编写 GUT 用例覆盖 `RuleEngine` 触发判定（[`00-tech-constraints.md`](00-tech-constraints.md) §九 强制项）。
- **关联文档**：[`modules/03-monster-anomaly-rules.md`](modules/03-monster-anomaly-rules.md)、[`monsters/001-da-zhi.md`](monsters/001-da-zhi.md)、[`00-design-pillars.md`](00-design-pillars.md)（Pillar 1）。
- **关联 Pillar**：Pillar 1（**本工作流是 Pillar 1 的核心承载**）。
- **验收门禁**：`RuleEngine` GUT 用例 100% 通过；在编辑器内可切换 `.tres` 文件并观察到不同的规则触发结果；关键失败规则均有非空 `learnable_hint`。
- **关联风险**：R-01；规则可读性风险（玩家无法推理 → 退化为随机惊吓）。

---

### P2-2 大只 AI 四阶段行为

- **目标**：勾选 [`00-vertical-slice.md`](00-vertical-slice.md) §4 前 3 项（通常不可见 + 间接反馈可判断 + 四阶段流程不随机传送）；同时验证 P1-1 遗留的 VS §1 第 2 项（行为差异产生不同怪物判断结果，通过观察怪物对噪声等级的响应确认）。
- **主要工作**：
  1. 用行为树/状态机插件搭建大只四阶段流程：潜伏 → 试探 → 搜索 → 追猎，依据 [`monsters/001-da-zhi.md`](monsters/001-da-zhi.md)。
  2. 大只寻路使用 P1-2 配置的 `NavigationRegion2D`。
  3. 现形仅在两种以上特定条件下短暂触发（条件来自 P2-1 的 `RuleResource`）。
- **关联文档**：[`modules/03-monster-anomaly-rules.md`](modules/03-monster-anomaly-rules.md)、[`monsters/001-da-zhi.md`](monsters/001-da-zhi.md)。
- **关联 Pillar**：Pillar 1。
- **验收门禁**：大只按四阶段 AI 在副本中运行，不出现无规则随机传送；玩家可通过行为变化区分当前 AI 阶段；VS §1 第 2 项可勾选（不同噪声等级引发可观察的怪物行为差异）。
- **关联风险**：行为树插件与 Godot 4.x 兼容性。

---

### P2-3 恐怖感知与压力反馈

- **目标**：勾选 [`00-vertical-slice.md`](00-vertical-slice.md) §2 全部 5 项（三类反馈 + 强度区分 + 首次现形 + 理智干扰）。
- **主要工作**：
  1. 心跳、手电闪烁、环境异响三类反馈共用同一份 `PressureLevel` 数据源（数据驱动原则）。
  2. 强空间化音频：`AudioStreamPlayer2D` + Attenuation，按 [`00-tech-constraints.md`](00-tech-constraints.md) §六.4 强制启用；AudioBus 分组（心跳 / 闪烁 / 环境各独立总线）。
  3. 理智干扰渲染走 Shader，禁止使用未压缩 4K。
  4. 第一次进入副本必须触发大只至少一次弱光现形（2–3 秒）。
- **关联文档**：[`modules/04-horror-perception-pressure.md`](modules/04-horror-perception-pressure.md)。
- **关联 Pillar**：Pillar 1（反馈须可推理）+ Pillar 2（理智低 = 信息变差）。
- **验收门禁**：[`00-vertical-slice.md`](00-vertical-slice.md) §2 全部 5 项可勾选；VS §1 第 2 项已在 P2-2 勾选；**注：压力反馈-规则口述盲测（"我是被什么规则杀的"）推迟至 P3-1 完成后执行**，此时玩家已能通过线索理解规则。
- **关联风险**：反馈过载（玩家麻木）/ 反馈不足（无法判断）。

---

## 六、P3 阶段：线索、解谜与结算

**阶段目标**：玩家能在副本中收集线索、推理出三条路径（逃离/击杀/收容），并触发对应结算屏幕。本阶段的"通关"还不依赖原形养成，只验证"单次副本的信息闭环"。

---

### P3-1 线索系统与规则推理

- **目标**：勾选 [`00-vertical-slice.md`](00-vertical-slice.md) §5 全部 7 项（3 逃离 + 3 击杀 + 5 收容线索 + 可推理 + 怪物反应验证）。
- **主要工作**：
  1. 使用 **Dialogic 2** 编辑可拾取线索（笔记、对话、电台），保持低代码（[`00-tech-constraints.md`](00-tech-constraints.md) §五）。
  2. 每条线索关联到一条或多条 `RuleResource`，被拾取后写入 `GameState.knownClues`。
  3. 至少一条收容线索通过怪物对特定物品/行为的反应间接验证（与 P2-1 `RuleEngine` 联动）。
- **关联文档**：[`modules/05-clues-puzzles-rule-deduction.md`](modules/05-clues-puzzles-rule-deduction.md)。
- **关联 Pillar**：Pillar 1。
- **验收门禁**：[`00-vertical-slice.md`](00-vertical-slice.md) §5 全部 7 项可勾选；线索表已通过 [`00-glossary.md`](00-glossary.md) 术语校对；**盲测玩家在死亡后能口述"我是被什么规则杀的"**（此时线索系统已就绪，该条件从 P2-3 延续至此验收）。
- **关联风险**：信息过载、线索冗余导致推理路径崩溃。

---

### P3-2 副本目标、弱点与收容仪式

- **目标**：勾选 [`00-vertical-slice.md`](00-vertical-slice.md) §4 后 3 项（弱点可执行击杀 + 三步收容仪式可推理 + 击杀/收容产出差异）。
- **主要工作**：
  1. 大只弱点与收容三步仪式均以 `RuleResource` 表达，玩家可通过线索推理出步骤。
  2. 击杀和收容成功各有明确触发判定，产出不同品质原形（由 P4 接收）。
- **关联文档**：[`modules/03-monster-anomaly-rules.md`](modules/03-monster-anomaly-rules.md)、[`monsters/001-da-zhi.md`](monsters/001-da-zhi.md)。
- **关联 Pillar**：Pillar 1。
- **验收门禁**：[`00-vertical-slice.md`](00-vertical-slice.md) §4 全部 6 项可勾选。
- **关联风险**：收容仪式步骤过长或线索太隐晦 → 玩家只走逃离路线。

---

### P3-3 副本目标结算系统

- **目标**：勾选 [`00-vertical-slice.md`](00-vertical-slice.md) §6（四种结算 + 数值展示 + 错误收容惩罚）。
- **主要工作**：
  1. `SettlementCalculator` 单独成系统，输入：路径标志、剩余 HP、拾取列表、规则触发记录；输出：四种结算之一与对应数值。
  2. 三档奖励差："收容 > 击杀 > 逃离"在素材量 / 原形质量 / 叙事条目三维同时拉开。
  3. 错误收容惩罚扣减基地资源并在结算页显示（基地资源由 P5 接入，此阶段可用占位值验证）。
  4. 编写 GUT 用例覆盖 `SettlementCalculator`（[`00-tech-constraints.md`](00-tech-constraints.md) §九 强制项）。
- **关联文档**：[`modules/06-objectives-settlement.md`](modules/06-objectives-settlement.md)。
- **关联 Pillar**：Pillar 2（收容奖励最高 ↔ 高阶异常注意度上升的伏笔）。
- **验收门禁**：[`00-vertical-slice.md`](00-vertical-slice.md) §6 全部 5 项可勾选；`SettlementCalculator` GUT 用例 100% 通过。
- **关联风险**：奖励曲线倒挂（玩家认为逃离才划算）。

---

### P3-4 玩家死亡与复活流程

- **目标**：补完 [`00-vertical-slice.md`](00-vertical-slice.md) §1 第 4 项（死亡后从基地复活，副本状态重置，带入资源损失）。
- **主要工作**：
  1. 死亡信号经 `EventBus` 触发 `GameState` 切换至基地场景（基地此阶段仅为占位场景）。
  2. 副本资源损失占位计算（正式逻辑由 P4 搜刮模块补全）。
  3. 读取本次死亡或失败关联的 `RuleResource.learnable_hint`，显示一条最低学习反馈；若无法定位规则，显示通用提示并记录缺失规则 ID。
- **关联文档**：[`modules/01-player-control-exploration.md`](modules/01-player-control-exploration.md)。
- **关联 Pillar**：Pillar 2。
- **验收门禁**：[`00-vertical-slice.md`](00-vertical-slice.md) §1 第 4 项可勾选；死亡到复活整个流程无脚本红字；死亡后至少能看到一条来自 `learnable_hint` 的可学习提示。
- **关联风险**：场景切换状态丢失。

---

## 七、P4 阶段：搜刮深度与原形养成

**阶段目标**：资源循环成立——玩家为了养成素材主动承担风险，原形三路线可投喂、可锁定、有副作用。`SaveSystem` 在本阶段正式接入并通过 GUT 验证。

---

### P4-1 搜刮与资源系统

- **目标**：勾选 [`00-vertical-slice.md`](00-vertical-slice.md) §7（带入区上限 + 三类物资 + 危险区选择压力 + 死亡返还率）。
- **主要工作**：
  1. 物资分类（生存 / 解谜 / 养成）以 `ItemResource (.tres)` 数据表达，批量数据用 CSV → tres 导入（[`00-tech-constraints.md`](00-tech-constraints.md) §五）。
  2. 背包带入格上限与死亡返还比例（默认 65%）作为 `Config` 参数，便于调参。
  3. 危险区物资分布与 P1-2 房间池绑定；高价值养成素材集中在高风险区域。
- **关联文档**：[`modules/07-looting-resources.md`](modules/07-looting-resources.md)。
- **关联 Pillar**：Pillar 2（"为养成深入危险区"是核心张力来源）。
- **验收门禁**：[`00-vertical-slice.md`](00-vertical-slice.md) §7 全部 4 项可勾选。
- **关联风险**：囤积破坏循环（与 [`00-risk-register.md`](00-risk-register.md) 基地纯安全风险联动）。

---

### P4-2 原形养成系统

- **目标**：勾选 [`00-vertical-slice.md`](00-vertical-slice.md) §8（三路线 + 0%~60% 可回拨 + 60% 锁定与外貌变化 + 三能力原型 + 副作用）。
- **主要工作**：
  1. `OriginResource` 持有：路线进度（拟人/恐怖/工具三轴）、稳定度、当前阶段、副作用列表。
  2. 0%–60% 反向投喂回拨 + 稳定度损耗；60% 锁定 + 外貌变化提示；全部逻辑在数据资源层，不进脚本层。
  3. 三条路线各产出一个可携带能力原型（提示 / 威慑 / 活体手电）。
- **关联文档**：[`modules/08-origin-acquisition-growth.md`](modules/08-origin-acquisition-growth.md)。
- **关联 Pillar**：Pillar 2（**本工作流是 Pillar 2 的核心承载**）。
- **验收门禁**：[`00-vertical-slice.md`](00-vertical-slice.md) §8 全部 6 项可勾选。
- **关联风险**：[`00-risk-register.md`](00-risk-register.md) R-01（养成变强 → 副本失去恐怖感）。

---

### P4-3 存档系统

- **目标**：`SaveSystem` 正式接入玩家进度，确保存档跨重启可恢复。
- **主要工作**：
  1. 进入基地时触发自动存档，使用 Godot `ResourceSaver` 或 JSON（[`00-tech-constraints.md`](00-tech-constraints.md) §四.6，可读格式，禁止不可读二进制）。
  2. 存档写入版本字段，为后续兼容性迁移预留分支入口。
  3. 编写 GUT 用例覆盖存档读写（[`00-tech-constraints.md`](00-tech-constraints.md) §九 强制项）。
- **关联文档**：[`00-tech-constraints.md`](00-tech-constraints.md) §四.6。
- **关联 Pillar**：—。
- **验收门禁**：`SaveSystem` GUT 用例 100% 通过；重启 Godot 后存档正确恢复 `OriginResource` 全部字段。
- **关联风险**：存档格式不可读 → 调试效率极低。

---

## 八、P5 阶段：原形助战与核心循环

**阶段目标**：原形可以被带入副本并发挥作用，完整循环"基地准备 → 副本 → 结算 → 基地养成 → 再次副本"端到端跑通，且第二次进入副本时体验与第一次有可观察差异。

---

### P5-1 基地场景（简化版）

- **目标**：勾选 [`00-vertical-slice.md`](00-vertical-slice.md) §10（四区域可自由移动 + 状态总览 + 携带选择 + 污染视觉提示）。
- **主要工作**：
  1. 基地 `.tscn` 包含收容室 / 仓库 / 准备区 / 档案入口，可自由移动。
  2. 污染度**只用视觉/音效暗示**，不显示数值（[`00-vertical-slice.md`](00-vertical-slice.md) §10 第 4 条）。
  3. 与 P4-3 `SaveSystem` 对接：进入基地即落档。
- **关联文档**：[`modules/10-base-management-research.md`](modules/10-base-management-research.md)。
- **关联 Pillar**：Pillar 2（基地不完全安全）。
- **验收门禁**：[`00-vertical-slice.md`](00-vertical-slice.md) §10 全部 4 项可勾选。
- **关联风险**：基地退化为无风险菜单（与 Pillar 2 直接冲突）。

---

### P5-2 原形携带与助战

- **目标**：勾选 [`00-vertical-slice.md`](00-vertical-slice.md) §9（携带选择 + 三类能力触发 + 致命伤代价）。
- **主要工作**：
  1. 出本前在基地准备区选择是否携带原形及携带哪只。
  2. 副本内三类能力（拟人提示 / 恐怖威慑 / 工具活体手电）各绑定路线，触发走 `EventBus`。
  3. 致命伤触发后按路线产生代价（拟人好感降 / 恐怖污染升 / 工具损坏），写回 `OriginResource` 并由 `SaveSystem` 持久化。
- **关联文档**：[`modules/09-origin-companion-support.md`](modules/09-origin-companion-support.md)。
- **关联 Pillar**：Pillar 2。
- **验收门禁**：[`00-vertical-slice.md`](00-vertical-slice.md) §9 全部 3 项可勾选。
- **关联风险**：能力打破恐怖体验（与 R-01 共因）。

---

### P5-3 核心循环端到端联调

- **目标**：勾选 [`00-vertical-slice.md`](00-vertical-slice.md) §11（一次完整循环 + 二次进入差异 + 完成方式影响后续准备）。
- **主要工作**：
  1. 联调"基地准备 → 副本 → 结算 → 基地养成 → 再次副本"全链路，纠正跨模块字段不一致。
  2. 重放二次副本对比：原形能力至少改变了一处场景表现。
  3. 实测三种结算各跑一遍，对照 [`modules/06-objectives-settlement.md`](modules/06-objectives-settlement.md) 与 [`modules/08-origin-acquisition-growth.md`](modules/08-origin-acquisition-growth.md) 描述的基地状态变化。
  4. 联调完成后冻结所有数据资源 schema，防止后续修改引入字段漂移。
- **关联文档**：所有模块文档；[`00-vertical-slice.md`](00-vertical-slice.md) §11。
- **关联 Pillar**：Pillar 1 + Pillar 2 同时校验。
- **验收门禁**：[`00-vertical-slice.md`](00-vertical-slice.md) §11 全部 3 项可勾选；至少 1 名非开发玩家盲测，能正确口述"我是怎么变强的，又因此变得多危险"。
- **关联风险**：跨模块字段漂移；P3-3 错误收容惩罚与 P5-1 基地资源扣减是最常见断点。

---

## 九、P6 阶段：垂直切片验收与性能基线

**阶段目标**：完成 [`00-vertical-slice.md`](00-vertical-slice.md) 所有 P0 验收项的最终勾选，达成性能指标，产出可分发 Windows `.exe` 交付物。**本阶段不新增功能，只修缺陷、跑基线、导出交付**。

---

### P6-1 全量 GUT 验证与缺陷修复

- **目标**：三类强制 GUT 用例（`RuleEngine` / `SaveSystem` / `SettlementCalculator`）全部 100% 通过，P0~P5 遗留缺陷清零。
- **主要工作**：
  1. 运行全部 GUT 用例，记录失败项并逐条修复。
  2. 针对 P5-3 盲测暴露的缺陷逐条分析原因，修复并回归验证。
  3. 确认 [`00-vertical-slice.md`](00-vertical-slice.md) §1~§11 所有 P0 项均可勾选。
- **关联文档**：[`00-tech-constraints.md`](00-tech-constraints.md) §九；[`00-vertical-slice.md`](00-vertical-slice.md) §1~§11。
- **关联 Pillar**：—。
- **验收门禁**：[`00-vertical-slice.md`](00-vertical-slice.md) P0 全部验收项勾选完毕；GUT 三类强制用例 100% 通过。
- **关联风险**：跨模块逻辑耦合导致修一处破另一处。

---

### P6-2 性能基线报告

- **目标**：达成 [`00-tech-constraints.md`](00-tech-constraints.md) §七 全部性能指标，并归档基线报告。
- **主要工作**：
  1. 用 Godot Profiler / Monitor 抓取副本与基地场景的完整基线：帧率 / 单帧脚本耗时 / 节点数 / 副本加载时间 / 内存 / 存档大小。
  2. 若单帧脚本耗时持续 > 8ms，按 [`00-tech-constraints.md`](00-tech-constraints.md) §十一 启动"仅热点改 GDExtension"回退路径——**禁止全栈迁移**。
  3. 基线报告归档至 `docs/perf/`。
- **关联文档**：[`00-tech-constraints.md`](00-tech-constraints.md) §七、§十一。
- **关联 Pillar**：—。
- **验收门禁**：副本 60fps 稳定；单帧脚本 < 4ms；节点数 < 2000；加载 < 5s；存档 < 5MB；内存 < 1.5GB；基线报告文件存在。
- **关联风险**：GDScript 性能不足；插件运行时开销超预期。

---

### P6-3 Windows 交付物导出

- **目标**：产出符合 [`00-tech-constraints.md`](00-tech-constraints.md) §十二 四条校验的 Windows 64-bit `.exe` 单文件包。
- **主要工作**：
  1. 导出 Windows 64-bit `.exe` 单文件包。
  2. 逐项校验：启动到主菜单 ≤ 3 秒 / 完整循环 ≤ 10 分钟 / 无脚本红字 / 存档重启后正确恢复。
- **关联文档**：[`00-tech-constraints.md`](00-tech-constraints.md) §十二。
- **关联 Pillar**：—。
- **验收门禁**：四条交付校验全部通过；包可由非开发者无额外依赖运行。
- **关联风险**：导出依赖路径在 Windows 上与编辑器内路径不一致。

---

## 十、P7 阶段：体验打磨与氛围补完

**阶段目标**：勾选 [`00-vertical-slice.md`](00-vertical-slice.md) P1 验收项全部 4 条，修复 P6 盲测暴露的反馈体验问题，接通副本动态危险度第一档以验证 R-01 缓解路径。**本阶段不新增内容量，只打磨已有体验**。

---

### P7-1 氛围与叙事补完

- **目标**：勾选 [`00-vertical-slice.md`](00-vertical-slice.md) P1 全部 4 条（基地不完全安全氛围 + 电台引导 + 收容档案增量 + 死亡规则提示）。
- **主要工作**：
  1. 基地增加随机异响 / 物品轻微位移等"被污染过的氛围细节"（Pillar 2：基地不完全安全）。
  2. 电台第一通话脚本走 Dialogic 2，依据 [`modules/11-narrative-worldbuilding.md`](modules/11-narrative-worldbuilding.md) 与 [`00-open-questions.md`](00-open-questions.md) Q-01（异常事件幸存者 + 旧机构候选执行者）。
  3. 大只档案页收容成功后扩写，与 [`monsters/001-da-zhi.md`](monsters/001-da-zhi.md) 一致。
  4. 死亡复盘提示打磨：沿用 P3-4 已接入的 `RuleResource.learnable_hint`，只增强节奏、文案和演出，不在 P7 首次补功能。
- **关联文档**：[`modules/10-base-management-research.md`](modules/10-base-management-research.md)、[`modules/11-narrative-worldbuilding.md`](modules/11-narrative-worldbuilding.md)、[`monsters/001-da-zhi.md`](monsters/001-da-zhi.md)。
- **关联 Pillar**：Pillar 1（死亡复盘要可学习）+ Pillar 2（基地不完全安全）。
- **验收门禁**：[`00-vertical-slice.md`](00-vertical-slice.md) P1 4 条全部勾选。
- **关联风险**：叙事注水稀释循环节奏；建议每条 P1 文本量先订字数上限再写。

---

### P7-2 难度与反馈参数打磨

- **目标**：在不增加内容量的前提下，将 P6 盲测暴露的反馈痛点收敛；接通副本动态危险度第一档。
- **主要工作**：
  1. 汇总 P5-3 盲测中发现的"反馈过载 / 反馈不足"案例，逐条回写 [`modules/04-horror-perception-pressure.md`](modules/04-horror-perception-pressure.md) 关键参数表。
  2. 通过 `Config` 资源调参三类反馈强度曲线，**不改代码**。
  3. 副本动态危险度接通第一档：第二次进入同一副本时，`RuleEngine` 新增 1 条 `RuleResource`，验证 [`00-risk-register.md`](00-risk-register.md) R-01 的缓解路径。
- **关联文档**：[`modules/02-dungeon-generation-map.md`](modules/02-dungeon-generation-map.md)、[`modules/04-horror-perception-pressure.md`](modules/04-horror-perception-pressure.md)、[`modules/12-progression-difficulty-longterm-growth.md`](modules/12-progression-difficulty-longterm-growth.md)、[`00-risk-register.md`](00-risk-register.md) R-01。
- **关联 Pillar**：Pillar 1 + Pillar 2。
- **验收门禁**：同一玩家二次进入同一副本，自报"和上一次有规则上的不同，而不是只是数值更难"；R-01 在风险登记中降级为"已缓解"。
- **关联风险**：R-01。

---

## 十一、P8 阶段：工程化与发布管线

**阶段目标**：将 P6 的"一次性导出"升级为可重复、低成本的发布流程；落地 CI；完成全部文档与开放问题的收尾，为可能的第二阶段立项留好接口。

---

### P8-1 CI 与自动化测试管线

- **目标**：每次 main 分支提交自动运行 GUT + Godot headless 导出，保证主干持续可发布。
- **主要工作**：
  1. GitHub Actions：Godot headless 导出 Windows + 跑 GUT 三类强制测试（[`00-tech-constraints.md`](00-tech-constraints.md) §八）。
  2. 存档兼容性：`SaveSystem` 写入版本字段；引入"老存档读不动 → 显式提示并迁移"分支。
- **关联文档**：[`00-tech-constraints.md`](00-tech-constraints.md) §八、§九。
- **关联 Pillar**：—。
- **验收门禁**：CI 在 main 分支每次提交均自动跑通；导出包可由非开发者按 README 步骤复现；存档版本字段存在。
- **关联风险**：插件升级破坏 P6 行为 → CI 必须包含一次完整 GUT 运行。

---

### P8-2 数据资源 Schema 校验加固

- **目标**：防止后期内容扩充引起数据格式腐烂；确保 Codex 生成数据资源时有机器可验证的约束。
- **主要工作**：
  1. 完善 `/tools/` 中全部 schema 校验脚本（`@tool`），覆盖 `RuleResource` / `OriginResource` / `ItemResource` / `MonsterProfile`。
  2. CI 管线中加入 schema 校验步骤；任何字段不合规导致导出失败。
- **关联文档**：[`00-tech-constraints.md`](00-tech-constraints.md) §四。
- **关联 Pillar**：—。
- **验收门禁**：CI 管线在 schema 不合规的测试 `.tres` 输入下能正确报错并阻断构建。
- **关联风险**：Schema 校验覆盖不全 → 后期引入 P8-1 无法检出的字段腐烂。

---

### P8-3 文档收尾与第二阶段接口预留

- **目标**：复审全部设计决策与后续问题，整理风险登记，走查模块文档"后续扩展方向"节，确保第二阶段可直接立项而不返工。
- **主要工作**：
  1. 把 P0~P7 阶段实测中形成的设计决策回填 [`00-open-questions.md`](00-open-questions.md)，关闭已决问题，新增第二阶段才需要回答的问题。
  2. [`00-risk-register.md`](00-risk-register.md) 中"已缓解 / 已关闭"项整理归档。
  3. 走查所有模块文档"后续扩展方向"节，确认与现有数据资源 schema 不冲突；冲突项升级为新 Open Question。
  4. 对照 [`00-next-stage-expansions.md`](00-next-stage-expansions.md) 复核所有延后项：仍保留的写入下一阶段立项草案，已不需要的关闭并记录理由。
  5. 所有顶层文档版本号统一推进一档，彼此引用无版本错配、无悬挂链接。
- **关联文档**：所有模块文档"后续扩展方向"节、[`00-open-questions.md`](00-open-questions.md)、[`00-risk-register.md`](00-risk-register.md)、[`00-next-stage-expansions.md`](00-next-stage-expansions.md)。
- **关联 Pillar**：—。
- **验收门禁**：顶层文档版本一致；无悬挂引用；所有 Open Questions 状态明确（已定案 / 后续阶段细化且有默认方案）；[`00-risk-register.md`](00-risk-register.md) 无滞留"开放"且已可关闭的条目。
- **关联风险**：文档腐化 → 与代码脱节，影响 Codex 对上下文的准确理解。

---

## 十二、跨阶段约束（P0 ~ P8 全程生效）

下列约束对每个工作流均生效，不再在工作流内重复列出。任何违反需在本文档版本记录中留痕并回填 [`00-open-questions.md`](00-open-questions.md)。

1. **Pillar 优先**：任何设计/实现冲突先用 [`00-design-pillars.md`](00-design-pillars.md) 裁决。
2. **技术红线**：[`00-tech-constraints.md`](00-tech-constraints.md) §十 禁止事项 8 条 + §五 插件采纳门槛 + §六 美术与音频约束 + §七 性能指标——全部强制，不因阶段早晚而豁免。
3. **单例白名单**：仅允许 5 个 Autoload（[`00-tech-constraints.md`](00-tech-constraints.md) §四.1）；新增须书面评审。
4. **数据驱动**：业务数据进 `/data/`，不进 `/scripts/`（[`00-tech-constraints.md`](00-tech-constraints.md) §三）。
5. **通信方式**：跨模块只能走 signal + EventBus（[`00-tech-constraints.md`](00-tech-constraints.md) §四.2）；禁止跨模块直接调用节点方法。
6. **文档同步**：每个工作流完成后，必须更新对应模块文档的版本记录与 [`00-glossary.md`](00-glossary.md)（[`00-tech-constraints.md`](00-tech-constraints.md) §八.4）。
7. **Codex 协作**：单文件 ~400 行上限，中文+英文术语对照（[`00-tech-constraints.md`](00-tech-constraints.md) §一.5）。
8. **输入与资源 ID 稳定**：输入只读 Input Map action；玩法逻辑引用稳定 `resource_id` / manifest key，不把物理按键或裸文件路径写死为公共契约。
9. **延后项显式登记**：任何不进入 P1~P6 的想法都必须写入 [`00-next-stage-expansions.md`](00-next-stage-expansions.md) 或对应模块"后续扩展方向"，不得在第一阶段无记录扩范围。

---

## 十三、阶段门禁汇总

| 门禁 | 必要条件 |
|---|---|
| **P0 通过** | 已通过：空项目可运行；Autoload 五件套就绪；Q-13~Q-20 全部决策；插件采纳门槛核查完成；Schema 框架文件存在并通过示例校验 |
| **P1 通过** | 微切片门禁通过；Input Map action 全部存在；VS §1 第 1 项和第 3 项勾选（第 2 项噪声接口实现，验收推迟至 P2；第 4 项推迟至 P3）+ VS §3 全勾；副本可徒步完整探索 |
| **P2 通过** | VS §2 全部 5 项 + VS §4（前 3 项）+ VS §1 第 2 项 全勾；`RuleEngine` GUT 用例 100% 通过；关键失败规则均有 `learnable_hint` |
| **P3 通过** | VS §4 全勾 + VS §5 全勾 + VS §6 全勾；VS §1 第 4 项勾选；`SettlementCalculator` GUT 用例 100% 通过；死亡后能显示 `learnable_hint`，盲测玩家死后能口述"我是被什么规则杀的" |
| **P4 通过** | VS §7 + VS §8 全勾；`SaveSystem` GUT 用例 100% 通过；存档重启恢复正常 |
| **P5 通过** | VS §9 + VS §10 + VS §11 全勾；至少 1 名非开发玩家盲测通过；Schema 已冻结 |
| **P6 通过（垂直切片验收）** | VS 全部 P0 验收项全勾；GUT 三类强制用例全过；性能基线达标；`.exe` 四条交付校验通过 |
| **P7 通过** | VS P1 验收项 4 条全勾；R-01 降级为"已缓解" |
| **P8 通过** | CI 持续绿；Schema 校验在 CI 中生效；顶层文档版本一致、无悬挂引用；`00-next-stage-expansions.md` 已完成复核 |
| **进入第二阶段（本计划外）** | P8 通过 + 新立项实施计划文档 v3.x |

---

## 十四、风险跟踪指引

- 所有风险编号统一使用 [`00-risk-register.md`](00-risk-register.md) 的 R-XX。
- 工作流"关联风险"字段仅做指针，不复述风险描述与缓解策略。
- 每完成一个工作流，须回到 [`00-risk-register.md`](00-risk-register.md) 评估关联风险等级是否变动；若变动，同步推进风险登记文档版本。
- 触发 [`00-tech-constraints.md`](00-tech-constraints.md) §十一 回退预案的工作流，必须在本文档版本记录中留痕。

---

## 十五、已定案开放项（指针）

下列条目影响本计划，详见 [`00-open-questions.md`](00-open-questions.md)、[`00-art-direction.md`](00-art-direction.md) 与 [`00-tech-constraints.md`](00-tech-constraints.md) §十三。Q-01 ~ Q-20 当前均已定案；没有用户待确认阻塞项：

| 编号 | 内容 | 影响阶段 |
|---|---|---|
| Q-01 | 已定案：玩家为异常事件幸存者 + 旧机构候选执行者 | P7-1 电台脚本 |
| Q-02 | 已定案：电台偏中立但有信息盲区和协议残缺 | P5-1 / P7-1 |
| Q-03 | 已定案：旧机构同时把人类和异常当作收容材料 | P7-1 / 后续叙事 |
| Q-04 | 已定案：结局主轴采用 70% 固定阈值，45%~55% 为模糊带 | P8 / 第三阶段 |
| Q-05 | 已定案：`radio_relation_score` 为 -100~+100 | P7 / 第三阶段 |
| Q-06 | 已定案：破败校园与旧机构为间接关联 | P3-1 / P7-1 |
| Q-07 | 已定案：第一阶段收容室容量 3，第二阶段 6~8 | P5-1 / 后续基地 |
| Q-08 | 已定案：大只击杀弱点为广播依附 + 仓库封锁链 | P3-2 |
| Q-13 | 已定案：2.5D Live 分层资产规格，不使用像素瓦片路线 | P0 / P1-2 |
| Q-14 | 已定案：厚涂精美二次元风格，不使用像素风或低多边形手绘 | P0 全美术 |
| Q-15 | 已定案：GDScript，不引入 C# | P0 |
| Q-16 | 已定案：LimboAI v1.7.0 | P0-3 / P1-1 / P2-2 |
| Q-17 | 已定案：第一阶段不引入 Steam SDK | P8-1 |
| Q-18 | 已定案：第一阶段仅中文 `zh_CN` | P7-1 |
| Q-19 | 已定案：Krita / CSP / Photoshop 分层源文件 + PNG 导出，默认免费底基推荐 Krita | P1-2 / 全美术 |
| Q-20 | 已定案：Godot 原生 2D Live 管线，Live2D / Spine 不作为第一阶段底基 | P1-2 / P2-3 / P5 |

P7-1 不再因 Q-01 阻塞；其前置仍为 P6-4。

---

## 版本记录

### v2.5.4 - 2026-05-14

- 记录 P2-3 压力反馈系统已完成：`PressureLevel`、心跳、手电闪烁、环境氛围总线、理智干扰 Shader 与首次入场大只现形均已接入。
- 当前实施入口推进至 P2-4 怪物线索占位规则池施工。

### v2.5.3 - 2026-05-14

- 记录 P2-2 大只 AI 骨架、MonsterProfile、LimboHSM 阶段节点与规则驱动阶段变化已完成。
- 当前实施入口推进至 P2-3 恐怖感知与压力反馈施工。

### v2.5.2 - 2026-05-14

- 记录 P2-1 RuleEngine 与大只最低规则资源已完成。
- 当前实施入口推进至 P2-2 大只 AI 四阶段行为施工。

### v2.5.1 - 2026-05-14

- 记录 P1 阶段出口走查已通过，并指向 `docs/perf/p1-review.md`。
- 当前实施入口推进至 P2-1 RuleEngine 与怪物异常规则施工。

### v2.5.0 - 2026-05-14

- 同步 `game-concept.md` v0.8.2、`00-tech-constraints.md` v1.3.1、`00-vertical-slice.md` v1.0.4、`00-next-stage-expansions.md` v1.0.0。
- P1 新增微切片门禁：Input Map、玩家基础动词、走廊 + 2 房间、1 躲藏点、1 交互占位物、1 变化事件和噪声事件先行验证。
- P2/P3 前置死亡学习反馈最低版：`RuleResource.learnable_hint` 字段在规则阶段填入，死亡复活流程负责显示。
- P7-1 调整为死亡复盘演出和文案打磨，不再承担最低功能首次实现。
- P8-3 增加下一阶段扩展清单复核，所有延后项必须可追踪。

### v2.4.1 - 2026-05-14

- 同步 `game-concept.md` v0.8.1、`00-art-direction.md` v1.0.0、`00-open-questions.md` v1.5.0、`00-tech-constraints.md` v1.3.0 与 `00-vertical-slice.md` v1.0.3。
- P0-2 配置决策范围从 Q-13 ~ Q-18 扩展到 Q-13 ~ Q-20，补入美术制作底基与 2.5D Live 动画技术路线。
- P1-2 手工副本地图工作流增加 `00-art-direction.md` 作为关联文档，确保破败校园场景按 Godot 原生 2D Live 管线施工。

### v2.4.0 - 2026-05-14

- 同步 `game-concept.md` v0.8.0、`00-open-questions.md` v1.4.0 与 `00-tech-constraints.md` v1.2.3。
- Q-01 ~ Q-08 全部定案，P7-1 解除叙事开放问题阻塞。
- §十五改为“无用户待确认阻塞项”，列出 Q-01 ~ Q-08 与 Q-13 ~ Q-18 的计划影响阶段。

### v2.3.1 - 2026-05-14

- 同步 `00-tech-constraints.md` v1.2.2：GoPeak v2.3.7 作为 dev-only Godot MCP 协作工具引入，不作为正式游戏运行依赖。

### v2.3.0 - 2026-05-14

- 记录 P0 命令行门禁结果：空项目启动、Autoload 白名单、schema 校验、GUT sanity test 均已通过。
- 同步 `00-tech-constraints.md` v1.2.1：Dialogic 2 已安装入库，但 P0 默认不启用 editor plugin，避免自动注册运行时 Autoload。
- P0 schema 校验口径改为命令行脚本，编辑器菜单入口延后至 P8-2 加固。

### v2.2.0 - 2026-05-14

- 同步 `00-open-questions.md` v1.3.0 与 `00-tech-constraints.md` v1.2.0：Q-15 ~ Q-18 全部定案。
- P0-2 配置决策工作流解除阻塞：脚本语言为 GDScript，AI 插件为 LimboAI v1.7.0，不接 Steam SDK，第一阶段仅中文。
- §十五从"待用户决策与已定案开放项"改为"已定案开放项"，保留 Q-01 为后续叙事打磨待决。

### v2.1.0 - 2026-05-14

- 同步总设定 v0.7.0 与技术规约 v1.1.0：Q-13 / Q-14 改为已定案。
- P1-2 地图工作流从最终 `TileMap` 瓦片搭建改为 2.5D Live 场景嵌套 + 分层 Sprite / Parallax / Collision / Navigation 搭建。
- §十五开放项指针更新为"已定案 + 待用户决策"混合状态，保留 Q-15 ~ Q-18 为后续阻塞项。
- 同步垂直切片 v1.0.1：程序化连通走廊改为第三阶段再评估。

### v2.0.1 - 2026-05-14

复检修正（4 处）：
- **Bug-1 修复**：P1-1 目标从"勾选 VS §1 前 3 项"改为"第 1、3 项"，第 2 项（噪声→怪物反应）接口在 P1 实现、验收推迟至 P2-2；阶段门禁表 P1 行同步更新。
- **Bug-2 修复**：P2-3 的"盲测玩家死后能口述规则"门禁不可达（P2 阶段线索未装），将该条件移至 P3-1 验收；P2-2 同时接收 VS §1 第 2 项的最终验收；阶段门禁表 P2/P3 行同步更新。
- **Bug-3 修复**：§二 参考表中 VS 文档角色描述从"P0 阶段唯一验收单"改为带消歧注释，明确其内部 P0/P1 标签与本计划 P0~P8 为独立体系。
- **Bug-4 修复**：P7-2 主要工作中删去不存在的"P6 盲测"引用，仅保留"P5-3 盲测"。

### v2.0.0 - 2026-05-14

- 重构阶段结构：将 v1.0.0 的 P0/P1 两阶段（共 17 个工作流）细分为 P0~P8 九阶段（共 25 个工作流）。
- 每个阶段拥有独立、可独立验证的交付物，不再将工程底座、可玩原型、系统开发、循环联调、性能验收、体验打磨、工程化七类工作堆积于同一阶段。
- 新增"阶段总览"一节，明确各阶段与 [`00-vertical-slice.md`](00-vertical-slice.md) 节号的对应关系。
- 新增 P6-3（Windows 交付物导出）、P8-2（Schema 校验加固）两个独立工作流，确保工程质量保障可被独立验证。
- 将 P3-4（死亡复活）从 P1-1 拆出，独立置于 P3（怪物接入后才有意义）。
- 阶段门禁汇总表更新为 9 行，精确对应各阶段出口条件。
- 全文与 [`00-design-pillars.md`](00-design-pillars.md) v1.0.0、[`00-tech-constraints.md`](00-tech-constraints.md) v1.0.0、[`00-vertical-slice.md`](00-vertical-slice.md) v1.0.0 对齐。

### v1.0.0 - 2026-05-14

- 建立项目实施计划文档。
- 划分 P0（垂直切片原型，13 个工作流）与 P1（体验打磨与可交付化，4 个工作流）两阶段，不设具体时间。
