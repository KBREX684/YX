extends Node
class_name PlayerLimboState
## PlayerStateMeta —— 玩家移动状态的元数据节点（已脱离 LimboAI）。
##
## 历史保留：原 P1-1 使用 LimboHSM/LimboState；B2 移除 LimboAI 依赖后改为纯 Node
## 元数据载体。`player.gd` 不再调用 dispatch；这些节点只用于在编辑器中查看每个
## 状态的标称噪声等级与名称，便于后续接入可视化状态机时迁移。

@export var state_id: StringName = &"idle"
@export_range(0, 3, 1) var noise_level: int = 0
