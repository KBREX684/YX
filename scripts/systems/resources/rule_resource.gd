extends Resource
class_name RuleResource
## RuleResource —— 怪物异常规则数据契约
##
## 关联模块：docs/modules/03-monster-anomaly-rules.md
## TASK-P0-6：仅声明 @export 字段，业务逻辑由 RuleEngine（P2 阶段）实现。
## 设计原则（docs/00-tech-constraints.md §四.4）：
##   每条规则一个 .tres；触发条件、效果、可学习线索全部数据驱动。

## 全局唯一规则 ID（如 "rule_corridor_dont_run"）。
@export var id: String = ""

## 触发条件列表。每一项为 Dictionary，键值约定见 03 模块文档。
## 示例：[{"type": "player_action", "action": "run"}, {"type": "zone", "zone_id": "corridor"}]
@export var trigger_conditions: Array = []

## 触发效果。Dictionary，键值由 RuleEngine 解释。
## 示例：{"type": "monster_phase", "monster_id": "big", "phase": "hunt"}
@export var effect: Dictionary = {}

## 解锁该规则需要的线索 ID（空串表示无前置线索，默认可见）。
@export var clue_unlock_id: String = ""

## 玩家可学习提示（在档案/线索 UI 中展示的友好文本）。
@export_multiline var learnable_hint: String = ""
