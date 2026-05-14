# P3 阶段出口走查记录

版本：v0.1.0
关联实施计划：[`../00-implementation-plan.md`](../00-implementation-plan.md) v2.6.4
关联工程任务书：[`../00-engineering-tasks.md`](../00-engineering-tasks.md) v1.6.4
关联垂直切片：[`../00-vertical-slice.md`](../00-vertical-slice.md) v1.0.5
创建日期：2026-05-14
最后更新：2026-05-14
状态：阻塞（待非开发者盲测）

---

## 一、结论

P3（线索、解谜与结算）的自动化工程出口已通过，但正式阶段门禁尚未通过，当前阻塞项为：至少 1 名非开发者盲测后，能在死亡或失败后口述“我是被什么规则杀的”，并能根据线索解释击杀/收容的关键规则。

在盲测完成前，不进入 P4 搜刮深度与原形养成施工。

---

## 二、设计

P3 的设计边界保持收敛：只验证单次副本的信息闭环，不提前接入正式搜刮、原形养成、基地经营或完整档案 UI。

- 线索层负责让玩家获得逃离、击杀、收容三条路径的信息，不在 P3-1 小阶段强行做完整人工验收。
- 执行层通过 `ObjectiveResolver` 和 `RuleEngine` 验证弱点击杀、三步收容和错误收容，避免目标逻辑硬编码到怪物脚本。
- 结算层通过 `SettlementCalculator` 统一输出四类结果，奖励曲线采用三维分工：逃离偏素材量，击杀为中间策略，收容偏原形质量与叙事条目。
- 死亡复活层只接通基地占位和最低学习提示，正式 65% 拾取返还率由 P4-1 接管。

---

## 三、搭建

| 门禁项 | 结果 | 证据 |
|---|---|---|
| VS §4 第 1-3 项：大只现形、间接反馈、AI 阶段流程 | 通过 | P2 已完成并在 P3 全量 GUT 回归中保持通过 |
| VS §4 第 4 项：线索揭示弱点并可执行击杀 | 自动化通过，人工推理待盲测 | `ObjectiveResolver` + `test_objective_execution.gd` 覆盖弱点击杀 |
| VS §4 第 5 项：三步收容仪式可执行 | 自动化通过，人工推理待盲测 | `test_objective_execution.gd` 覆盖三步收容与错误收容 |
| VS §4 第 6 项：击杀/收容产出区别 | 通过 | `SettlementCalculator` 输出不稳定/稳定原形品质差异 |
| VS §5：逃离/击杀/收容线索与怪物反应验证 | 自动化通过，人工路径待盲测 | 11 条 `ClueResource`、Dialogic `.dtl` 占位、`ClueBook` 与收容行为验证规则 |
| VS §6：四种结算、数值展示、错误收容惩罚 | 通过 | `SettlementPayoffResource`、`data/settlement_payoffs.tres`、`SettlementScreen`、`test_settlement_calculator.gd` |
| VS §1 第 4 项：死亡后基地复活、状态重置、资源损失 | 工程链路通过，真实搜刮返还待 P4 | `GameState.respawn_at_base()`、`DeathFeedbackResolver`、`test_death_respawn.gd` |

---

## 四、审计修复

- 修正 [`../00-vertical-slice.md`](../00-vertical-slice.md) §6 的奖励验收口径：不再要求“素材量/原形质量/叙事条目全部收容最高”，改为三维分工，保持与模块 06 和 P3-3 实装一致。
- `GameState.gd` 保持 100 行，没有突破 P0 Autoload 轻量边界；死亡反馈解析逻辑放在普通系统脚本 `DeathFeedbackResolver`。
- P3 关键系统未发现对 `rule_da_zhi_` 的生产硬编码；硬编码规则 ID 仅出现在测试中，用于固定验收样例。
- P3 关键脚本未发现 `get_parent()` 反向依赖。
- 美术资源仍为占位，但玩家、怪物、线索、仪式、基地占位均保留 `placeholder_asset_note` 或可见占位标注，方便后续替换 2.5D Live 厚涂资产。
- GoPeak 编辑器桥接当前因 `127.0.0.1:6506` 被占用不可连接；已使用 GoPeak `resource_dependencies` 完成 P3 关键场景/脚本依赖审计，未发现循环依赖。
- `AGENTS.md` 未被暂存或提交。

---

## 五、验收

| 命令 / 工具 | 结果 |
|---|---|
| `godot --headless --path . -s res://addons/gut/gut_cmdln.gd -gconfig=res://tests/.gutconfig.json -gexit` | 通过：73/73 tests，482 asserts |
| `godot --headless --path . --script res://tools/validate_schemas.gd` | 通过：35 个资源检查，结果为 OK 或既定 SKIP |
| `godot --headless --path . --check-only --quit scenes/dungeon/abandoned_school.tscn` | 通过 |
| `godot --headless --path . --check-only --quit scenes/base/base_placeholder.tscn` | 通过 |
| GoPeak `resource_dependencies` | `abandoned_school.tscn`、`base_placeholder.tscn`、`settlement_calculator.gd`、`game_state.gd` 无循环依赖 |
| `git diff --check` | 通过；无 whitespace error |
| 非开发者盲测 | 未执行，阻塞 P3 正式通过 |

---

## 六、非开发者盲测脚本

执行人：用户或非本功能开发者。被测者不阅读 `RuleResource`、脚本、工程任务书或本走查文档，只接触游戏内线索、结算页、死亡提示和可见占位内容。

1. 让被测者在副本中自由探索，至少触发一次死亡或失败。
2. 死亡/失败后询问：“你觉得自己是被什么规则杀死或惩罚的？”
3. 让被测者收集击杀线索后，询问：“大只的弱点是什么？你打算怎样利用它？”
4. 让被测者收集全部收容线索后，询问：“收容仪式需要哪三步？哪一步做错会出问题？”
5. 让被测者完成至少一种非逃离结算后，询问：“击杀和收容给你的奖励有什么区别？”

通过标准：

- 能口述至少 1 条死亡/失败关联规则，且与 `RuleResource.learnable_hint` 指向一致。
- 能说出大只弱点的核心触发条件，不要求逐字复述线索文本。
- 能按正确顺序描述三步收容仪式，并指出错误收容会带来基地物资损失或污染代价。
- 能区分逃离、击杀、收容的主要奖励方向：逃离偏素材，击杀为中间策略，收容偏原形质量与叙事条目。

---

## 七、延后项

以下内容不阻塞 P3 自动化工程出口，但阻塞或延后到后续阶段：

- 非开发者盲测尚未执行，阻塞 P3 正式通过与 P4 启动。
- P4-1：正式搜刮物品、背包带入格和死亡拾取返还率 65%。
- P4-2：原形路线、稳定度、投喂与路线锁定。
- P5：基地正式场景、档案入口、原形携带与完整循环联调。
- P7：死亡失败提示的正式演出与文案打磨。
- P8-2：P3 新增资源的 CI schema 强化。

---

## 版本记录

### v0.1.0 - 2026-05-14

- 建立 P3 阶段出口走查记录。
- 记录自动化验收、GoPeak 依赖审计、奖励口径修复和非开发者盲测阻塞项。
