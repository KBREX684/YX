extends Node
class_name DaZhiLimboState
## 大只阶段元数据节点（已脱离 LimboAI）。详见 player_limbo_state.gd 注释。

@export var phase_id: StringName = &"dormant"
@export_range(0, 5, 1) var threat_level: int = 0
