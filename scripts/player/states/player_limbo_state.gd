extends LimboState
class_name PlayerLimboState
## PlayerLimboState —— 玩家移动状态的 LimboAI 元数据节点。
##
## P1-1 先用 LimboHSM/ LimboState 搭建状态节点骨架；输入采集和最小运动
## 注入仍由 player.gd 完成，P1 后续可把转移条件迁入可视化状态机。

@export var state_id: StringName = &"idle"
@export_range(0, 3, 1) var noise_level: int = 0
