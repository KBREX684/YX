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
@onready var _state_machine: Node = $StateMachine

var _phase: StringName = PHASE_DORMANT
var _is_manifested := false


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
	_navigation_agent.target_position = target_position


func tick_navigation(_delta: float = 0.016) -> void:
	if _phase == PHASE_DORMANT or _phase == PHASE_PROBING:
		velocity = Vector2.ZERO
		return
	if _navigation_agent.is_navigation_finished():
		velocity = Vector2.ZERO
		return
	var next_position := _navigation_agent.get_next_path_position()
	var direction := (next_position - global_position).normalized()
	velocity = direction * _speed_for_phase()


func apply_rule_context(_rule_id: String, context: Dictionary) -> void:
	var effect: Dictionary = context.get("rule_effect", {})
	match String(effect.get("type", "")):
		"phase_change":
			_set_phase(StringName(effect.get("phase", PHASE_SEARCH)))
		"manifestation":
			manifest(float(effect.get("duration", 2.5)))
		"weakness_window":
			_set_phase(PHASE_PROBING)


func manifest(duration: float = 2.5) -> void:
	_is_manifested = true
	_sync_visual()
	if duration > 0.0 and is_inside_tree():
		get_tree().create_timer(duration).timeout.connect(clear_manifestation, CONNECT_ONE_SHOT)


func clear_manifestation() -> void:
	_is_manifested = false
	_sync_visual()


func _on_rule_triggered(rule_id: String, context: Dictionary) -> void:
	apply_rule_context(rule_id, context)


func _set_phase(next_phase: StringName) -> void:
	if _phase == next_phase:
		return
	_phase = next_phase
	if _state_machine.has_method("dispatch"):
		_state_machine.call("dispatch", _phase)
	EventBus.monster_phase_changed.emit(entity_id, _phase)


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


func _sync_visual() -> void:
	if _visual == null:
		return
	var alpha := manifestation_alpha if _is_manifested else 0.0
	_visual.modulate = Color(_visual.modulate.r, _visual.modulate.g, _visual.modulate.b, alpha)
