# 项目实施计划 Implementation Plan

版本：v1.0.0
关联总设定版本：v0.6.2
关联技术规约版本：[`00-tech-constraints.md`](00-tech-constraints.md) v1.0.0
关联垂直切片版本：[`00-vertical-slice.md`](00-vertical-slice.md) v1.0.0
创建日期：2026-05-14
最后更新：2026-05-14

---

## 一、用途

本文档是 YX 项目的**工程实施纲领**，与设计层的 [`00-design-pillars.md`](00-design-pillars.md) 和工程层的 [`00-tech-constraints.md`](00-tech-constraints.md) 配套：

- Design Pillars 决定"做什么是合理的"。
- Tech Constraints 决定"用什么技术做是合理的"。
- **本文档决定"按什么次序、按什么粒度推进，才能把上面两者落到 [`00-vertical-slice.md`](00-vertical-slice.md) 的 P0 验收单上"。**

本文档**不规定具体日历时间**（一人独立开发 + Codex 协助，时间预算不稳定且易诱发范围蔓延）。一切排程以"上一阶段验收门禁通过"为唯一前置条件。

阶段划分采用与 [`00-vertical-slice.md`](00-vertical-slice.md) 一致的 **P0 / P1** 体系：

| 阶段 | 含义 | 出口条件 |
|---|---|---|
| **P0** | 垂直切片原型（Vertical Slice） | [`00-vertical-slice.md`](00-vertical-slice.md) 全部 P0 验收项勾选完毕 + 性能基线达标 |
| **P1** | 体验打磨与可交付化（Polish & Shippable） | P0 全过 + 本文档 §四 所列 P1 工作流的验收门禁全过 |

> 本文档明确**不**涉及第二阶段（更多副本主题、研究树、第二只怪、程序化走廊、多结局等），上述项见各模块"后续扩展方向"节，于 P1 验收后另行立项。

---

## 二、参考文档总览

下列文档共同构成本计划的"上位输入"，每个工作流都必须在其"关联文档"字段中显式回链至少一篇。

### 顶层约束

| 文档 | 角色 |
|---|---|
| [`docs/game-concept.md`](game-concept.md) | 总设定与核心循环来源 |
| [`docs/00-design-pillars.md`](00-design-pillars.md) | 设计裁决（Pillar 1 / Pillar 2） |
| [`docs/00-tech-constraints.md`](00-tech-constraints.md) | 技术裁决（引擎、目录、Autoload、低代码工具链、禁止事项） |
| [`docs/00-vertical-slice.md`](00-vertical-slice.md) | P0 阶段唯一验收单 |
| [`docs/00-glossary.md`](00-glossary.md) | 术语统一来源 |
| [`docs/00-risk-register.md`](00-risk-register.md) | 风险跟踪（R-XX 编号） |
| [`docs/00-open-questions.md`](00-open-questions.md) | 未决问题（Q-XX 编号） |

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

## 三、P0 阶段：垂直切片原型

P0 的唯一目标：让 [`00-vertical-slice.md`](00-vertical-slice.md) 中"核心循环验证目标"的三个问题答案全部为"是"。

工作流划分原则：**先工程底座，再单模块自闭，最后跨模块联调与性能验收**。模块顺序按"被依赖深度"由深至浅排，越靠前越是后续模块的运行前提。

每个工作流统一字段如下：
- **目标**：本工作流要让什么 P0 验收项变为可勾选。
- **主要工作**：粗粒度任务列表（不下沉到代码级）。
- **关联文档**：模块文档 + 必要的顶层文档。
- **关联 Pillar**：受哪条 Pillar 裁决。
- **验收门禁**：本工作流可被宣告完成的条件（必须可勾选 / 可观察）。
- **关联风险**：会触发哪些 R-XX 风险，需重点观察。

---

### P0-00 工程底座（Foundation）

- **目标**：搭建项目骨架，使后续 11 个工作流可以在统一约定下并行推进；本身不直接对应 [`00-vertical-slice.md`](00-vertical-slice.md) 中的验收项，但为所有后续验收项提供运行环境。
- **主要工作**：
  1. 按 [`00-tech-constraints.md`](00-tech-constraints.md) §三 建立目录结构（`/assets` `/data` `/scenes` `/scripts` `/tests` `/tools`）。
  2. 创建 Autoload 白名单中的 5 个单例骨架：`GameState` / `EventBus` / `SaveSystem` / `AudioManager` / `Config`（仅接口与空实现）。
  3. 评审并装入受限插件（Dialogic 2、LimboAI 或 Godot State Charts、GUT），按 [`00-tech-constraints.md`](00-tech-constraints.md) §五 插件采纳门槛逐项核对，决策结果回填 Q-16。
  4. 建立 `.gitignore`（含 `.import` / `.tmp`），评估 Git LFS 是否启用（音频/视频 > 10MB 时启用）。
  5. 建立 `RuleResource` / `OriginResource` / `MonsterProfile` 等核心数据资源类型的 `.gd` 框架文件（无业务逻辑，仅字段定义）。
  6. 引入 GUT，写一个示例测试用例确保 CI 兼容。
- **关联文档**：[`00-tech-constraints.md`](00-tech-constraints.md)（§二 / §三 / §四 / §五）、[`00-open-questions.md`](00-open-questions.md)（Q-13 ~ Q-18）。
- **关联 Pillar**：—（基础设施，受双 Pillar 同等约束）。
- **验收门禁**：
  - 空项目可在 Godot 4.x 中无报错运行并显示一个占位主菜单。
  - 五个 Autoload 在 `Project Settings` 中已注册，相互之间无循环依赖。
  - `GUT` 可执行示例用例并打印通过。
  - Q-13 ~ Q-18 全部由用户拍板并回填到本文档与 [`00-tech-constraints.md`](00-tech-constraints.md)。
- **关联风险**：[`00-risk-register.md`](00-risk-register.md) 中 GDScript 性能、插件停更两条；目前等级中。

---

### P0-01 玩家控制与探索

- **目标**：勾选 [`00-vertical-slice.md`](00-vertical-slice.md) §1（行走/奔跑/蹲伏/开门/拾取/阅读/躲藏 + 手电电量 + 死亡复活）。
- **主要工作**：
  1. 实现玩家 `CharacterBody2D`，状态机使用 §P0-00 选定的行为树/状态机插件，**禁止**单文件多层 if/else（[`00-tech-constraints.md`](00-tech-constraints.md) §四.3）。
  2. 行为产生的"噪声等级"作为信号经 `EventBus` 广播，供 P0-03 怪物 AI 订阅（**禁止**直接调用怪物节点方法）。
  3. 手电系统：电量资源化（`.tres`），电量阈值触发视觉反馈走 P0-04。
  4. 死亡 → 基地复活流程：通过 `GameState` 切场景，资源损失走 P0-07。
- **关联文档**：[`modules/01-player-control-exploration.md`](modules/01-player-control-exploration.md)。
- **关联 Pillar**：Pillar 1（行为差异要可被怪物"学习"，不是孤立操作手感）。
- **验收门禁**：[`00-vertical-slice.md`](00-vertical-slice.md) §1 全部 4 项可勾选。
- **关联风险**：手感与恐怖感平衡（R 系列待补；详见 [`00-risk-register.md`](00-risk-register.md)）。

---

### P0-02 副本地图（破败校园）

- **目标**：勾选 [`00-vertical-slice.md`](00-vertical-slice.md) §3（地图分区 + 一次变化事件 + 三路径不阻断 + 重玩房间池）。
- **主要工作**：
  1. 用 `TileMap` 手工搭建 1 个副本：入口 / 主走廊 / 4–6 候选房间 / 仪式房 / 出口。**禁止**程序化生成（[`00-tech-constraints.md`](00-tech-constraints.md) §十.3）。
  2. `NavigationRegion2D` 配置（为 P0-03 怪物寻路服务）。
  3. "变化事件" 由 `RuleResource` 驱动（走廊变长 / 门牌错乱 / 已探索房间出现新物品三选一），数据驱动可切换。
  4. 候选房间池抽取逻辑使用确定性随机种子，便于复盘。
- **关联文档**：[`modules/02-dungeon-generation-map.md`](modules/02-dungeon-generation-map.md)；与 [`00-risk-register.md`](00-risk-register.md) R-01（体验曲线塌陷）密切相关——本工作流是"动态危险度挂钩副本主题"的承载位。
- **关联 Pillar**：Pillar 1（地图变化必须可解释、可学习）。
- **验收门禁**：[`00-vertical-slice.md`](00-vertical-slice.md) §3 全部 4 项可勾选；从入口到任一目标路径出口的单次步行 ≤ 90 秒（防止地图过大稀释恐怖密度）。
- **关联风险**：R-01。

---

### P0-03 怪物与异常规则（大只）

- **目标**：勾选 [`00-vertical-slice.md`](00-vertical-slice.md) §4，并为 §5、§6 提供运行时基础。
- **主要工作**：
  1. 实现 `RuleEngine`：消费 `RuleResource (.tres)` 列表，订阅 `EventBus`，输出"是否触发 / 触发了哪条规则 / 学习线索是否被解锁"。**所有规则禁止硬编码到怪物脚本**（[`00-tech-constraints.md`](00-tech-constraints.md) §四.4）。
  2. 用行为树/状态机插件搭建大只的 4 阶段流程：潜伏 → 试探 → 搜索 → 追猎，依据 [`monsters/001-da-zhi.md`](monsters/001-da-zhi.md)。
  3. 现形条件、弱点条件、收容三步仪式全部以 `RuleResource` 表达。
  4. 编写 GUT 用例覆盖 `RuleEngine` 触发判定（[`00-tech-constraints.md`](00-tech-constraints.md) §九 强制项）。
- **关联文档**：[`modules/03-monster-anomaly-rules.md`](modules/03-monster-anomaly-rules.md)、[`monsters/001-da-zhi.md`](monsters/001-da-zhi.md)、[`00-design-pillars.md`](00-design-pillars.md)（Pillar 1）。
- **关联 Pillar**：Pillar 1（**本工作流是 Pillar 1 的核心承载**）。
- **验收门禁**：[`00-vertical-slice.md`](00-vertical-slice.md) §4 全部 6 项可勾选；`RuleEngine` GUT 用例 100% 通过。
- **关联风险**：[`00-risk-register.md`](00-risk-register.md) R-01；规则可读性风险（玩家无法理解 → 退化为随机惊吓）。

---

### P0-04 恐怖感知与压力反馈

- **目标**：勾选 [`00-vertical-slice.md`](00-vertical-slice.md) §2（三类反馈 + 强度区分 + 至少一次现形 + 理智干扰）。
- **主要工作**：
  1. 心跳、手电闪烁、环境异响三类反馈共用同一份 `PressureLevel` 数据源（[`00-tech-constraints.md`](00-tech-constraints.md) 数据驱动原则）。
  2. 强空间化音频：`AudioStreamPlayer2D` + Attenuation，按 [`00-tech-constraints.md`](00-tech-constraints.md) §六.4 强制启用。
  3. AudioBus 分组：心跳 / 闪烁 / 环境 各独立总线，便于后期混音。
  4. 理智干扰渲染走 Shader（[`00-tech-constraints.md`](00-tech-constraints.md) §六，禁止使用未压缩 4K）。
- **关联文档**：[`modules/04-horror-perception-pressure.md`](modules/04-horror-perception-pressure.md)。
- **关联 Pillar**：Pillar 1（反馈必须可推理）+ Pillar 2（理智低 = 信息变差，是"变强变危险"的镜像）。
- **验收门禁**：[`00-vertical-slice.md`](00-vertical-slice.md) §2 全部 5 项可勾选；盲测玩家在死后能口述"我是被什么规则杀的"。
- **关联风险**：反馈过载（玩家麻木）/ 反馈不足（无法判断）。

---

### P0-05 线索与解谜

- **目标**：勾选 [`00-vertical-slice.md`](00-vertical-slice.md) §5（3 逃离 / 3 击杀 / 5 收容 线索 + 可推理 + 怪物反应验证）。
- **主要工作**：
  1. 使用 **Dialogic 2** 编辑可拾取线索（笔记、对话、电台），保持低代码（[`00-tech-constraints.md`](00-tech-constraints.md) §五）。
  2. 每条线索关联到一条或多条 `RuleResource`，被拾取后写入 `GameState.knownClues`。
  3. 至少一条收容线索通过怪物对玩家某物品/行为的反应间接验证（与 P0-03 联动）。
- **关联文档**：[`modules/05-clues-puzzles-rule-deduction.md`](modules/05-clues-puzzles-rule-deduction.md)。
- **关联 Pillar**：Pillar 1。
- **验收门禁**：[`00-vertical-slice.md`](00-vertical-slice.md) §5 全部 7 项可勾选；线索表已通过 [`00-glossary.md`](00-glossary.md) 术语校对。
- **关联风险**：信息过载、线索冗余。

---

### P0-06 副本目标与结算

- **目标**：勾选 [`00-vertical-slice.md`](00-vertical-slice.md) §6（四种结算 + 数值展示 + 错误收容惩罚）。
- **主要工作**：
  1. `SettlementCalculator` 单独成系统，输入：玩家路径标志、剩余 HP、拾取列表、规则触发记录；输出：四种结算之一与对应数值。
  2. 三档奖励差："收容 > 击杀 > 逃离"在素材量 / 原形质量 / 叙事条目三维同时拉开。
  3. 错误收容惩罚必须扣减基地资源并在结算页显示（与 P0-10 基地联动）。
  4. 编写 GUT 用例覆盖 `SettlementCalculator`（[`00-tech-constraints.md`](00-tech-constraints.md) §九 强制项）。
- **关联文档**：[`modules/06-objectives-settlement.md`](modules/06-objectives-settlement.md)。
- **关联 Pillar**：Pillar 2（收容奖励最高 ↔ 高阶异常注意度上升的伏笔）。
- **验收门禁**：[`00-vertical-slice.md`](00-vertical-slice.md) §6 全部 5 项可勾选；`SettlementCalculator` GUT 用例 100% 通过。
- **关联风险**：奖励曲线倒挂（玩家觉得逃离才划算）。

---

### P0-07 搜刮与资源

- **目标**：勾选 [`00-vertical-slice.md`](00-vertical-slice.md) §7（带入区上限 + 三类物资 + 危险区取舍 + 死亡返还率）。
- **主要工作**：
  1. 物资分类（生存 / 解谜 / 养成）以 `ItemResource (.tres)` 数据表达，导入用 CSV → tres（[`00-tech-constraints.md`](00-tech-constraints.md) §五）。
  2. 背包带入格与死亡返还比例（默认 65%）作为 `Config` 参数，便于调参。
  3. 危险区物资分布与 P0-02 房间池绑定。
- **关联文档**：[`modules/07-looting-resources.md`](modules/07-looting-resources.md)。
- **关联 Pillar**：Pillar 2（"为养成深入危险区"是核心张力来源）。
- **验收门禁**：[`00-vertical-slice.md`](00-vertical-slice.md) §7 全部 4 项可勾选。
- **关联风险**：囤积破坏循环（与 [`00-risk-register.md`](00-risk-register.md) 基地纯安全风险联动）。

---

### P0-08 原形获取与养成

- **目标**：勾选 [`00-vertical-slice.md`](00-vertical-slice.md) §8（三路线 + 60% 锁定 + 三能力原型 + 副作用）。
- **主要工作**：
  1. `OriginResource` 持有：路线进度（拟人/恐怖/工具三轴）、稳定度、当前阶段、副作用列表。
  2. 0–60% 反向投喂回拨 + 稳定度损耗，60% 锁定 + 外貌变化，写在数据资源层。
  3. 三条路线各产出一个可携带能力原型（提示 / 威慑 / 活体手电），与 P0-09 对接。
- **关联文档**：[`modules/08-origin-acquisition-growth.md`](modules/08-origin-acquisition-growth.md)。
- **关联 Pillar**：Pillar 2（**本工作流是 Pillar 2 的核心承载**）。
- **验收门禁**：[`00-vertical-slice.md`](00-vertical-slice.md) §8 全部 6 项可勾选。
- **关联风险**：[`00-risk-register.md`](00-risk-register.md) R-01（体验曲线塌陷）。

---

### P0-09 原形携带与助战（简化版）

- **目标**：勾选 [`00-vertical-slice.md`](00-vertical-slice.md) §9（携带 + 三类能力触发 + 致命伤代价）。
- **主要工作**：
  1. 出本前在基地准备区选择是否携带原形 + 携带哪只。
  2. 副本内三类能力分别绑定路线，触发走 `EventBus`。
  3. 致命伤触发后按路线产生代价（拟人好感降 / 恐怖污染升 / 工具损坏），写回 `OriginResource` 并由 `SaveSystem` 持久化。
- **关联文档**：[`modules/09-origin-companion-support.md`](modules/09-origin-companion-support.md)。
- **关联 Pillar**：Pillar 2。
- **验收门禁**：[`00-vertical-slice.md`](00-vertical-slice.md) §9 全部 3 项可勾选。
- **关联风险**：能力打破恐怖体验（与 R-01 共因）。

---

### P0-10 基地（简化版）

- **目标**：勾选 [`00-vertical-slice.md`](00-vertical-slice.md) §10（四区域 + 状态总览 + 携带选择 + 污染视觉提示）。
- **主要工作**：
  1. 基地 `.tscn` 含收容室 / 仓库 / 准备区 / 档案入口；可自由移动。
  2. 污染度第一阶段**只用视觉/音效暗示**（[`00-vertical-slice.md`](00-vertical-slice.md) §10 第 4 条），不显示数值。
  3. 与 `SaveSystem` 对接：进入基地即落档（[`00-tech-constraints.md`](00-tech-constraints.md) §四.6，可读格式）。
- **关联文档**：[`modules/10-base-management-research.md`](modules/10-base-management-research.md)。
- **关联 Pillar**：Pillar 2（基地不完全安全）。
- **验收门禁**：[`00-vertical-slice.md`](00-vertical-slice.md) §10 全部 4 项可勾选；`SaveSystem` GUT 用例 100% 通过（[`00-tech-constraints.md`](00-tech-constraints.md) §九 强制项）。
- **关联风险**：基地变菜单（与 Pillar 2 直接冲突）。

---

### P0-11 核心循环联调

- **目标**：勾选 [`00-vertical-slice.md`](00-vertical-slice.md) §11（一次完整循环 + 二次进入差异 + 完成方式影响后续）。
- **主要工作**：
  1. 联调"基地准备 → 副本 → 结算 → 基地养成 → 再次副本"端到端，纠正跨模块字段不一致。
  2. 重放二次副本对比：原形能力至少改变了一处场景表现。
  3. 实测三种结算各跑一遍，对照基地状态变化是否符合 [`modules/06-objectives-settlement.md`](modules/06-objectives-settlement.md) 与 [`modules/08-origin-acquisition-growth.md`](modules/08-origin-acquisition-growth.md) 描述。
- **关联文档**：上述所有模块文档。
- **关联 Pillar**：Pillar 1 + Pillar 2 同时校验。
- **验收门禁**：[`00-vertical-slice.md`](00-vertical-slice.md) §11 全部 3 项可勾选；至少 1 名非开发玩家盲测一次完整循环，能正确口述"我是怎么变强的，又因此变得多危险"。
- **关联风险**：跨模块字段漂移；建议在本工作流冻结所有数据资源 schema。

---

### P0-12 性能基线与交付物

- **目标**：让 [`00-tech-constraints.md`](00-tech-constraints.md) §七、§十二 所列指标全部达标，并产出可分发交付物。
- **主要工作**：
  1. 用 Godot Profiler 抓取副本与基地两个场景的基线（帧率、单帧脚本耗时、节点数、副本加载、内存、存档大小）。
  2. 若 GDScript 单帧脚本耗时持续 > 8ms，按 [`00-tech-constraints.md`](00-tech-constraints.md) §十一 启动"仅热点改 GDExtension"回退路径——**禁止全栈迁移**。
  3. 导出 Windows 64-bit `.exe` 单文件包；确认启动 ≤ 3 秒、循环 ≤ 10 分钟、无脚本红字、存档可重启恢复（[`00-tech-constraints.md`](00-tech-constraints.md) §十二）。
- **关联文档**：[`00-tech-constraints.md`](00-tech-constraints.md) §七、§十一、§十二。
- **关联 Pillar**：—。
- **验收门禁**：性能基线报告归档（建议放入 `docs/perf/`）；`.exe` 单文件通过四条交付校验。
- **关联风险**：GDScript 性能不足；插件运行时异常。

---

## 四、P1 阶段：体验打磨与可交付化

P1 仅在 P0 全部验收通过后启动。P1 的目标不是"做更多内容"，而是把 P0 已经成立的核心循环**润色到可对外发布的成色**，并补上 P0 时被显式延后的 4 条 P1 验收项与必要的工程化能力。

P1 同样**不**做以下事项（仍属第二阶段，见 [`00-vertical-slice.md`](00-vertical-slice.md) "已排除项"）：第二个副本主题、第二只怪、原形组合、设施升级、研究树、多结局、程序化走廊。

---

### P1-01 氛围与叙事补完

- **目标**：勾选 [`00-vertical-slice.md`](00-vertical-slice.md) "P1 验收项" 全部 4 条（基地不完全安全氛围、电台引导、收容档案增量、失败后规则提示）。
- **主要工作**：
  1. 基地：增加随机异响 / 物品轻微位移等"被污染过的氛围细节"，由 [`modules/10-base-management-research.md`](modules/10-base-management-research.md) 与 Pillar 2 联合定义。
  2. 电台第一通话脚本走 Dialogic 2 撰写，依据 [`modules/11-narrative-worldbuilding.md`](modules/11-narrative-worldbuilding.md) 与 [`00-open-questions.md`](00-open-questions.md) Q-01（玩家身份）当前定案。
  3. 大只档案页在收容成功后扩写，与 [`monsters/001-da-zhi.md`](monsters/001-da-zhi.md) 一致。
  4. 死亡复盘提示一句话，来自被触发的 `RuleResource` 的"事后提示"字段。
- **关联文档**：[`modules/10-base-management-research.md`](modules/10-base-management-research.md)、[`modules/11-narrative-worldbuilding.md`](modules/11-narrative-worldbuilding.md)、[`monsters/001-da-zhi.md`](monsters/001-da-zhi.md)。
- **关联 Pillar**：Pillar 1（死亡复盘要可学习）+ Pillar 2（基地不完全安全）。
- **验收门禁**：[`00-vertical-slice.md`](00-vertical-slice.md) P1 4 条全部勾选。
- **关联风险**：叙事注水稀释循环节奏；建议每条 P1 项的文本量先订上限再写。

---

### P1-02 难度与反馈打磨

- **目标**：在不增加内容量的前提下，让 P0 暴露出的盲测痛点收敛。
- **主要工作**：
  1. 汇总 P0-11 盲测中发现的"反馈过载 / 反馈不足"案例，逐条回写 [`modules/04-horror-perception-pressure.md`](modules/04-horror-perception-pressure.md) 关键参数表。
  2. 通过 `Config` 资源调参三类反馈强度曲线，**不改代码**。
  3. 副本动态危险度（[`modules/02-dungeon-generation-map.md`](modules/02-dungeon-generation-map.md) 已设计的"规则复杂度提升"机制）至少接通一档：第二次进入同一副本时新增 1 条 `RuleResource`，验证 [`00-risk-register.md`](00-risk-register.md) R-01 的缓解路径。
- **关联文档**：[`modules/02-dungeon-generation-map.md`](modules/02-dungeon-generation-map.md)、[`modules/04-horror-perception-pressure.md`](modules/04-horror-perception-pressure.md)、[`modules/12-progression-difficulty-longterm-growth.md`](modules/12-progression-difficulty-longterm-growth.md)、[`00-risk-register.md`](00-risk-register.md) R-01。
- **关联 Pillar**：Pillar 1 + Pillar 2。
- **验收门禁**：同一玩家二次进入同一副本时，自报"和上一次有规则上的不同，而不是只是数值更难"。
- **关联风险**：R-01。

---

### P1-03 工程化与发布管线

- **目标**：把 P0-12 的"一次性导出"升级为可重复、低成本的发布流程，且开始落地 [`00-tech-constraints.md`](00-tech-constraints.md) §八 的"可选 CI"。
- **主要工作**：
  1. GitHub Actions：Godot headless 导出 Windows + 跑 GUT 三类强制测试。
  2. 版本号策略写入 README：与 [`game-concept.md`](game-concept.md) 总版本号联动。
  3. 给所有 `RuleResource` / `OriginResource` 数据表加 schema 校验脚本（@tool 工具脚本，放 `/tools/`），防止后期数据腐烂。
  4. 存档兼容性：为 `SaveSystem` 写入版本字段；P1 阶段引入第一次"老存档读不动 → 显式提示并迁移"分支。
- **关联文档**：[`00-tech-constraints.md`](00-tech-constraints.md) §八、§九。
- **关联 Pillar**：—。
- **验收门禁**：CI 在 main 分支每次提交均自动跑通；导出包可由非开发者按 README 步骤复现。
- **关联风险**：插件升级破坏 P0 行为 → CI 必须包含一次完整 GUT 运行。

---

### P1-04 第二阶段铺垫（仅设计文档级，不进入交付）

- **目标**：在 P1 验收期间，把第二阶段会承接的几条线索"留好接口"，但**不**实现。仅作为文档级输出，便于 P1 结束后立项第二阶段时不返工。
- **主要工作**：
  1. 走查所有模块文档的"后续扩展方向"小节，确认与现有数据资源 schema 不冲突；冲突项升级为 Open Question。
  2. 把 P0 / P1 阶段实测得到的设计决策回填 [`00-open-questions.md`](00-open-questions.md)，关闭已决问题，新增第二阶段才需要回答的问题。
  3. 风险登记 [`00-risk-register.md`](00-risk-register.md) 中"已缓解 / 已关闭"项整理归档。
- **关联文档**：所有模块文档的"后续扩展方向"节、[`00-open-questions.md`](00-open-questions.md)、[`00-risk-register.md`](00-risk-register.md)。
- **关联 Pillar**：—。
- **验收门禁**：所有顶层文档版本号统一推进一档，且彼此引用一致；无悬挂引用、无版本错配。
- **关联风险**：文档腐化 → 与代码脱节。

---

## 五、跨阶段约束（贯穿 P0 与 P1）

下列约束对每个工作流均生效，不再在工作流内重复列出。任何违反需提交 PR 评审并回填 [`00-open-questions.md`](00-open-questions.md)。

1. **Pillar 优先**：任何工作流的设计/实现冲突先用 [`00-design-pillars.md`](00-design-pillars.md) 裁决。
2. **技术红线**：[`00-tech-constraints.md`](00-tech-constraints.md) §十 禁止事项 8 条；§五 插件采纳门槛；§六 美术与音频；§七 性能指标——全部强制。
3. **单例白名单**：仅允许 5 个 Autoload（[`00-tech-constraints.md`](00-tech-constraints.md) §四.1）。新增需评审。
4. **数据驱动**：业务数据进 `/data/`，不进 `/scripts/`（[`00-tech-constraints.md`](00-tech-constraints.md) §三）。
5. **通信方式**：跨模块只能走 signal + EventBus（[`00-tech-constraints.md`](00-tech-constraints.md) §四.2）。
6. **文档同步**：每个工作流完成后，必须更新对应模块文档的版本记录与 [`00-glossary.md`](00-glossary.md)（[`00-tech-constraints.md`](00-tech-constraints.md) §八.4）。
7. **Codex 协作**：单文件 ~400 行上限，中文+英文术语对照（[`00-tech-constraints.md`](00-tech-constraints.md) §一.5）。

---

## 六、阶段门禁汇总

| 门禁 | 必要条件 |
|---|---|
| **P0-00 完成** | Autoload 五件套就绪；选定插件落地；Q-13~Q-18 决策 |
| **P0 单工作流完成** | 对应 [`00-vertical-slice.md`](00-vertical-slice.md) 段落全部勾选 + 关联模块文档版本号推进 |
| **P0 总验收** | [`00-vertical-slice.md`](00-vertical-slice.md) P0 全过 + GUT 三类强制用例全过 + 性能基线达标 + `.exe` 单文件四条交付校验通过 |
| **P1 启动** | P0 总验收已签字 |
| **P1 总验收** | [`00-vertical-slice.md`](00-vertical-slice.md) P1 全过 + CI 持续绿 + 顶层文档版本一致 |
| **进入第二阶段（本计划外）** | P1 总验收 + 新立项实施计划文档 v2.x |

---

## 七、风险跟踪指引

- 所有风险编号统一使用 [`00-risk-register.md`](00-risk-register.md) 的 R-XX。
- 工作流"关联风险"字段仅做指针，不复述风险描述与缓解策略。
- 每完成一个工作流，须回到 [`00-risk-register.md`](00-risk-register.md) 评估关联风险等级是否变动；若变动，同步推进风险登记文档版本。
- 触发 [`00-tech-constraints.md`](00-tech-constraints.md) §十一 回退预案的工作流，必须在本文档版本记录中留痕。

---

## 八、待用户决策的开放项（指针）

下列条目影响本计划但当前未定，详见 [`00-open-questions.md`](00-open-questions.md) 与 [`00-tech-constraints.md`](00-tech-constraints.md) §十三：

| 编号 | 内容 | 影响工作流 |
|---|---|---|
| Q-13 | 像素分辨率 32×32 vs 64×64 | P0-00 / P0-02 |
| Q-14 | 像素 vs 低多边形手绘 | P0-00 全美术 |
| Q-15 | 是否允许 C# 替代 GDScript | P0-00（一旦改动需重评工具链） |
| Q-16 | LimboAI vs Godot State Charts | P0-00 / P0-01 / P0-03 |
| Q-17 | 是否引入 Steam SDK | P1-03 |
| Q-18 | 本地化范围（中文 / 中英） | P1-01 |
| Q-01 | 玩家身份来源 | P1-01 电台脚本 |

未决策前，工作流可基于 [`00-tech-constraints.md`](00-tech-constraints.md) §十三 的当前建议项推进，但**不得**写入硬编码假设。

---

## 版本记录

### v1.0.0 - 2026-05-14

- 建立项目实施计划文档。
- 划分 P0（垂直切片原型，13 个工作流）与 P1（体验打磨与可交付化，4 个工作流）两阶段，不设具体时间。
- 每个工作流统一字段：目标 / 主要工作 / 关联文档 / 关联 Pillar / 验收门禁 / 关联风险。
- 全文与 [`00-design-pillars.md`](00-design-pillars.md) v1.0.0、[`00-tech-constraints.md`](00-tech-constraints.md) v1.0.0、[`00-vertical-slice.md`](00-vertical-slice.md) v1.0.0 对齐。
- 明确跨阶段约束、阶段门禁、风险跟踪与开放项指针四节，禁止重复声明红线条款。
