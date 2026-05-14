extends Resource
class_name MonsterProfile
## MonsterProfile —— 怪物档案数据契约
##
## 关联模块：docs/modules/03-monster-anomaly-rules.md
## TASK-P0-6：仅声明 @export 字段，AI 行为由 P2 阶段插件实现。

## 全局唯一怪物 ID（如 "big"）。
@export var id: String = ""

## 显示名称（可本地化键或直接中文）。
@export var name: String = ""

## 该怪物绑定的所有规则 ID 列表（指向 RuleResource.id）。
@export var rule_ids: Array[String] = []

## 弱点规则 ID。玩家学习并满足此规则即可触发击杀路径。
@export var weakness_rule_id: String = ""

## 收容仪式规则 ID 序列（顺序敏感，错序触发"错误收容"）。
@export var containment_rule_ids: Array[String] = []
