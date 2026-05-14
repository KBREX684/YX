extends Node
## EventBus —— 跨模块信号总线
##
## TASK-P0-3：仅提供占位信号声明，订阅与触发在后续阶段实现。
## 红线（docs/00-tech-constraints.md §四.1/§四.2）：
##   - 本文件禁止 preload / 引用其他 Autoload 的具体类。
##   - 跨模块通信必须经由本总线，禁止直接调用其他模块节点方法。

# --- 探索与玩家行为 ----------------------------------------------------------
signal noise_emitted(level: int, position: Vector2, source_action_id: StringName) ## 玩家/物体发出声响
signal player_died                                          ## 玩家死亡
signal player_hidden_changed(is_hidden: bool)               ## 进入/离开躲藏点
signal flashlight_toggled(is_on: bool, battery: float)      ## 手电开关与电量更新

# --- 场景与流程 --------------------------------------------------------------
signal scene_changed(from_id: String, to_id: String)        ## 场景切换（基地 ↔ 副本）
signal dungeon_started(dungeon_id: String)
signal dungeon_finished(outcome: StringName)                ## escape/kill/contain/miscontain

# --- 怪物与规则 --------------------------------------------------------------
signal monster_phase_changed(monster_id: String, phase: StringName)
signal rule_triggered(rule_id: String, context: Dictionary)
signal monster_manifested(monster_id: String, duration: float)

# --- 线索与解谜 --------------------------------------------------------------
signal clue_collected(clue_id: String)
signal clue_decoded(clue_id: String, kind: StringName)      ## escape/kill/contain

# --- 结算与养成 --------------------------------------------------------------
signal settlement_ready(payload: Dictionary)
signal origin_progress_changed(origin_id: String, progress: Vector3)
signal origin_stage_locked(origin_id: String, route: StringName)

# --- 感知与压力 --------------------------------------------------------------
signal heartbeat_intensity_changed(intensity: float)        ## 0.0 ~ 1.0
signal sanity_changed(value: float)


func _ready() -> void:
	# 占位：在后续阶段连接日志/调试钩子。
	pass
