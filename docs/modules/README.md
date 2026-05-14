# 系统模块文档索引

版本：v0.5.2
关联总设定版本：v0.8.2
状态：微切片与延后项口径同步
创建日期：2026-05-14
最后更新：2026-05-14

## 用途

本目录用于存放游戏各系统模块的独立细化文档。总设定文档负责记录整体方向和模块关系，模块文档负责沉淀具体职责、功能范围、接口关系、原型范围和后续扩展。

后续每次修改模块文档时，需要同步更新该模块文档顶部版本号、最后更新时间和底部版本记录。如果修改影响整体结构，也要同步更新 `docs/game-concept.md`。

## 顶层文档（优先阅读）

| 文档 | 内容 |
|---|---|
| [Design Pillars](../00-design-pillars.md) | 2 条设计支柱，所有模块裁决依据 |
| [术语表 Glossary](../00-glossary.md) | 核心术语定义，模块文档直接引用 |
| [美术风格与制作底基 Art Direction](../00-art-direction.md) | 视觉最高规约：2.5D Live、厚涂精美二次元、动画管线与外包验收 |
| [技术选型与底基约束 Tech Constraints](../00-tech-constraints.md) | 工程最高规约：引擎、目录、架构、Input Map、manifest 与禁止事项 |
| [风险登记 Risk Register](../00-risk-register.md) | 已识别设计与工程风险及缓解策略 |
| [设计决策与开放问题 Open Questions](../00-open-questions.md) | 集中管理已定案设计问题与后续阶段问题；当前无用户待确认阻塞项 |
| [垂直切片验收清单](../00-vertical-slice.md) | 第一阶段原型的完成边界与验收标准 |
| [下一阶段扩展清单 Next-Stage Expansions](../00-next-stage-expansions.md) | 第一阶段暂缓项、延后原因与回归条件 |

## 模块列表

1. [玩家控制与探索模块](01-player-control-exploration.md)
2. [副本生成与地图模块](02-dungeon-generation-map.md)
3. [怪物与异常规则模块](03-monster-anomaly-rules.md)
4. [恐怖感知与压力模块](04-horror-perception-pressure.md)
5. [线索、解谜与规则推理模块](05-clues-puzzles-rule-deduction.md)
6. [副本目标与结算模块](06-objectives-settlement.md)
7. [搜刮与资源模块](07-looting-resources.md)
8. [原形获取与养成模块](08-origin-acquisition-growth.md)
9. [原形携带与助战模块](09-origin-companion-support.md)
10. [基地经营与研究模块](10-base-management-research.md)
11. [叙事与世界观模块](11-narrative-worldbuilding.md)
12. [进度、难度与长期成长模块](12-progression-difficulty-longterm-growth.md)

## 统一模板

每个模块文档默认包含（完整模板见 [`_module-template.md`](_module-template.md)）：

1. 模块定位
2. 关联 Design Pillars（新）
3. 关联 Art Direction（新）
4. 设计目标
5. 核心功能
6. 数据契约（输入/输出字段表）（新）
7. 关键参数表（新）
8. 关键流程（状态机/流程图）（新）
9. 与其他模块关系
10. 第一阶段原型范围
11. 验收标准 Acceptance Criteria（新）
12. KPI 指标（新）
13. 风险与依赖（新）
14. 后续扩展方向
15. 已确认设计决策
16. 已定案问题指针 / 后续阶段问题指针（详情见 `docs/00-open-questions.md`）
17. 版本记录

## 版本记录

### v0.5.2 - 2026-05-14

- 同步总设定版本至 v0.8.2。
- 顶层索引新增 `00-next-stage-expansions.md`，用于集中管理第一阶段延后项。
- 顶层索引补入 `00-tech-constraints.md`，避免模块入口漏掉工程最高规约。

### v0.5.1 - 2026-05-14

- 同步总设定版本至 v0.8.1。
- 顶层索引新增 `00-art-direction.md`，明确所有模块的视觉与动画实现需遵守美术底基。
- 统一模板目录项新增“关联 Art Direction”，与 `_module-template.md` v0.1.2 对齐。

### v0.5.0 - 2026-05-14

- 同步总设定版本至 v0.8.0。
- 顶层索引中 Open Questions 口径改为“设计决策与开放问题”，当前无用户待确认阻塞项。
- 统一模板目录项从“待确认问题”改为“已定案问题指针 / 后续阶段问题指针”。

### v0.4.1 - 2026-05-14

- 同步总设定版本至 v0.7.0。
- 模块目录口径跟随 2.5D Live + 厚涂精美二次元风格，以及第一阶段手工地图施工约束。

### v0.4.0 - 2026-05-14

- 同步总设定版本至 v0.6.0。
- 新增顶层文档索引表（Design Pillars / Glossary / Risk Register / Open Questions / Vertical Slice）。
- 更新统一模板：新增关联 Design Pillars、数据契约、关键参数表、关键流程、验收标准、KPI 指标、风险与依赖 6 项字段。
- 新增 `_module-template.md` 统一模板源文件。
- 新增 `docs/monsters/` 目录，含 `_monster-template.md` 和 `001-da-zhi.md`（大只 Monster Bible）。

### v0.3.0 - 2026-05-14

- 同步总设定版本至 v0.5.0。
- 叙事与世界观模块更新至 v0.3.0，确认主叙事闭环选择“遗留收容所”。
- 进度、难度与长期成长模块更新至 v0.3.0，确认结局采用多变量、多族群、多变体结构。

### v0.2.0 - 2026-05-14

- 同步总设定版本至 v0.4.0。
- 12 个模块文档均更新至 v0.2.0，写入第一轮待确认问题的设计定案。
- 保留玩家身份、基地身份、电台可信度和结局结构为待设计问题，并在叙事与长期成长模块中提供候选方案。

### v0.1.0 - 2026-05-14

- 建立系统模块文档索引。
- 记录 12 个模块文档的链接和统一写作模板。
