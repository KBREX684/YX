extends CharacterBody2D
class_name DaZhiAI

const PHASE_DORMANT := &"dormant"
const PHASE_PROBING := &"probing"
const PHASE_SEARCH := &"search"
const PHASE_HUNT := &"hunt"
const PHASE_DISPOSAL := &"disposal"

@export var entity_id := "da_zhi"
@export var probe_speed := 55.0
@export var search_speed := 95.0
@export var hunt_speed := 135.0
@export var manifestation_alpha := 0.3

@onready var _visual: CanvasItem = $Visual
@onready var _navigation_agent: NavigationAgent2D = $NavigationAgent2D

var _phase: StringName = PHASE_DORMANT
var _is_manifested := false
var _manifest_timer: SceneTreeTimer = null


func _ready() -> void:
	if not EventBus.rule_triggered.is_connected(_on_rule_triggered):
		EventBus.rule_triggered.connect(_on_rule_triggered)
	_sync_visual()


func _exit_tree() -> void:
	if EventBus.rule_triggered.is_connected(_on_rule_triggered):
		EventBus.rule_triggered.disconnect(_on_rule_triggered)


func _physics_process(delta: float) -> void:
	tick_navigation(delta)
	move_and_slide()


func get_phase() -> StringName:
	return _phase


func is_manifested() -> bool:
	return _is_manifested


func set_target_position(target_position: Vector2) -> void:
	if not is_finite(target_position.x) or not is_finite(target_position.y):
		push_warning("DaZhiAI.set_target_position: non-finite position ignored: %s" % str(target_position))
		return
	_navigation_agent.target_position = target_position


func tick_navigation(_delta: float = 0.016) -> void:
	# DORMANT 完全不动；PROBING 缓慢逼近目标（之前 bug：直接 return 导致永不移动）。
	if _phase == PHASE_DORMANT:
		velocity = Vector2.ZERO
		return
	if _navigation_agent.is_navigation_finished():
		velocity = Vector2.ZERO
		return
	var next_position := _navigation_agent.get_next_path_position()
	var direction := (next_position - global_position)
	if direction.length_squared() < 0.0001:
		velocity = Vector2.ZERO
		return
	velocity = direction.normalized() * _speed_for_phase()


func apply_rule_context(_rule_id: String, context: Dictionary) -> void:
	var effect: Dictionary = context.get("rule_effect", {})
	var effect_type := String(effect.get("type", "")).strip_edges().to_lower()
	match effect_type:
		"":
			# 上下文不携带 rule_effect 时按 no-op 静默通过；其他模块自行消费。
			return
		"phase_change":
			_set_phase(StringName(effect.get("phase", PHASE_SEARCH)))
		"manifestation":
			manifest(float(effect.get("duration", 2.5)))
		"weakness_window":
			_set_phase(PHASE_PROBING)
		_:
			push_warning("DaZhiAI.apply_rule_context: unhandled effect.type '%s'" % effect_type)


func manifest(duration: float = 2.5) -> void:
	_is_manifested = true
	_sync_visual()
	EventBus.monster_manifested.emit(entity_id, duration)
	EventBus.pressure_changed.emit(maxf(_pressure_for_phase(), 0.65))
	# 之前 bug：每次 manifest 都新建 timer，重叠时新的会被旧的 clear_manifestation 覆盖。
	# 修复：复用一个 timer 引用，旧的 timeout 信号在新建前断开。
	if _manifest_timer != null and _manifest_timer.timeout.is_connected(clear_manifestation):
		_manifest_timer.timeout.disconnect(clear_manifestation)
	_manifest_timer = null
	if duration > 0.0 and is_inside_tree():
		_manifest_timer = get_tree().create_timer(duration)
		_manifest_timer.timeout.connect(clear_manifestation, CONNECT_ONE_SHOT)


func show_apparition(duration: float = 2.5) -> void:
	manifest(duration)


func clear_manifestation() -> void:
	_is_manifested = false
	_manifest_timer = null
	_sync_visual()


func _on_rule_triggered(rule_id: String, context: Dictionary) -> void:
	apply_rule_context(rule_id, context)


func _set_phase(next_phase: StringName) -> void:
	if _phase == next_phase:
		return
	_phase = next_phase
	EventBus.monster_phase_changed.emit(entity_id, _phase)
	EventBus.pressure_changed.emit(_pressure_for_phase())


func _speed_for_phase() -> float:
	match _phase:
		PHASE_HUNT:
			return hunt_speed
		PHASE_SEARCH:
			return search_speed
		PHASE_PROBING:
			return probe_speed
		_:
			return 0.0


func _pressure_for_phase() -> float:
	match _phase:
		PHASE_DISPOSAL, PHASE_HUNT:
			return 1.0
		PHASE_SEARCH:
			return 0.7
		PHASE_PROBING:
			return 0.35
		_:
			return 0.0


func _sync_visual() -> void:
	if _visual == null:
		return
	var alpha := manifestation_alpha if _is_manifested else 0.0
	_visual.modulate = Color(_visual.modulate.r, _visual.modulate.g, _visual.modulate.b, alpha)
