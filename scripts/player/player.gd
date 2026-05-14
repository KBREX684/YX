extends CharacterBody2D
class_name PlayerController
## P1 微切片玩家控制器。只读取 Input Map action；跨模块事件走 EventBus。

const ACTION_MOVE_LEFT := "move_left"
const ACTION_MOVE_RIGHT := "move_right"
const ACTION_MOVE_UP := "move_up"
const ACTION_MOVE_DOWN := "move_down"
const ACTION_RUN := "run"
const ACTION_CROUCH := "crouch"
const ACTION_FLASHLIGHT := "flashlight"
const ACTION_INTERACT := "interact"
const ACTION_HIDE := "hide"
const ACTION_PAUSE := "pause"
const STATE_IDLE := &"idle"
const STATE_WALK := &"walk"
const STATE_RUN := &"run"
const STATE_CROUCH := &"crouch"
const STATE_HIDE := &"hide"
const STATE_INTERACT := &"interact"
const STATE_NOISE := {
	STATE_IDLE: 0,
	STATE_CROUCH: 1,
	STATE_WALK: 2,
	STATE_INTERACT: 2,
	STATE_RUN: 3,
	STATE_HIDE: 0,
}

@export var walk_speed: float = 140.0
@export var run_speed: float = 220.0
@export var crouch_speed: float = 70.0
@export var acceleration: float = 900.0
@export var friction: float = 1000.0
@export var flashlight_data: Resource
@onready var _flashlight: PointLight2D = $Flashlight
@onready var _state_machine: Node = $StateMachine
var _movement_state: StringName = STATE_IDLE
var _flashlight_enabled := false
var _flashlight_battery := 0.0
var _is_hidden := false
var _temp_inventory: Dictionary = {}
var _read_notes: Dictionary = {}

func _ready() -> void:
	if flashlight_data == null:
		flashlight_data = load("res://data/items/flashlight.tres")
	_flashlight_battery = _flashlight_float(&"battery_capacity")
	_sync_flashlight_visual()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(ACTION_FLASHLIGHT):
		set_flashlight_enabled(not _flashlight_enabled)
		get_viewport().set_input_as_handled()
	if event.is_action_pressed(ACTION_HIDE):
		_toggle_hidden()
		get_viewport().set_input_as_handled()
	if event.is_action_pressed(ACTION_INTERACT):
		_set_movement_state(STATE_INTERACT, &"interact")
		get_viewport().set_input_as_handled()
	if event.is_action_pressed(ACTION_PAUSE):
		get_tree().paused = not get_tree().paused
		get_viewport().set_input_as_handled()

func _physics_process(delta: float) -> void:
	var input_vector := Input.get_vector(ACTION_MOVE_LEFT, ACTION_MOVE_RIGHT, ACTION_MOVE_UP, ACTION_MOVE_DOWN)
	apply_movement_intent(input_vector, Input.is_action_pressed(ACTION_RUN), Input.is_action_pressed(ACTION_CROUCH), _dominant_action(input_vector), delta)
	move_and_slide()
	tick_flashlight(delta)

func apply_movement_intent(input_vector: Vector2, is_running: bool, is_crouching: bool, source_action_id: StringName, delta: float = 0.016) -> void:
	var next_state := _state_for(input_vector, is_running, is_crouching)
	_set_movement_state(next_state, source_action_id)
	var target_velocity := Vector2.ZERO
	if input_vector != Vector2.ZERO and not _is_hidden:
		target_velocity = input_vector.normalized() * _speed_for(next_state)
	var step := acceleration * delta if target_velocity != Vector2.ZERO else friction * delta
	velocity = velocity.move_toward(target_velocity, step)

func set_flashlight_enabled(enabled: bool) -> void:
	_flashlight_enabled = enabled and _flashlight_battery > 0.0
	_sync_flashlight_visual()
	EventBus.flashlight_toggled.emit(_flashlight_enabled, _flashlight_battery)

func tick_flashlight(delta: float) -> void:
	if not _flashlight_enabled:
		_sync_flashlight_visual()
		return
	_flashlight_battery = maxf(0.0, _flashlight_battery - _flashlight_float(&"battery_drain_per_second") * delta)
	if _flashlight_battery <= 0.0:
		_flashlight_enabled = false
	_sync_flashlight_visual()
	EventBus.flashlight_toggled.emit(_flashlight_enabled, _flashlight_battery)

func get_flashlight_battery() -> float:
	return _flashlight_battery

func is_flashlight_low() -> bool:
	return _flashlight_battery <= _flashlight_float(&"low_battery_threshold")

func get_movement_state() -> StringName:
	return _movement_state

func interact_with(target: Node) -> Dictionary:
	if target == null or not target.has_method("interact"):
		return {"result": "invalid"}
	_set_movement_state(STATE_INTERACT, &"interact")
	var payload: Dictionary = target.interact(self)
	_apply_interaction_payload(payload)
	return payload

func add_temp_item(item_id: StringName, amount: int = 1) -> void:
	_temp_inventory[item_id] = get_temp_item_count(item_id) + amount

func get_temp_item_count(item_id: StringName) -> int:
	return int(_temp_inventory.get(item_id, 0))

func mark_note_read(note_id: StringName, _text: String = "") -> void:
	_read_notes[note_id] = true

func has_read_note(note_id: StringName) -> bool:
	return bool(_read_notes.get(note_id, false))

func enter_hiding_spot() -> void:
	if not _is_hidden:
		_toggle_hidden()

func exit_hiding_spot() -> void:
	if _is_hidden:
		_toggle_hidden()

func is_hidden() -> bool:
	return _is_hidden

func _apply_interaction_payload(payload: Dictionary) -> void:
	match String(payload.get("result", "")):
		"picked_up":
			add_temp_item(StringName(payload.get("item_id", "")), int(payload.get("amount", 1)))
		"read":
			mark_note_read(StringName(payload.get("note_id", "")), String(payload.get("text", "")))
		"hidden":
			enter_hiding_spot()

func _state_for(input_vector: Vector2, is_running: bool, is_crouching: bool) -> StringName:
	if _is_hidden:
		return STATE_HIDE
	if input_vector == Vector2.ZERO:
		return STATE_IDLE
	if is_crouching:
		return STATE_CROUCH
	return STATE_RUN if is_running else STATE_WALK

func _set_movement_state(next_state: StringName, source_action_id: StringName) -> void:
	if _movement_state == next_state:
		return
	_movement_state = next_state
	if _state_machine.has_method("dispatch"):
		_state_machine.call("dispatch", next_state)
	EventBus.noise_emitted.emit(int(STATE_NOISE.get(next_state, 0)), global_position, source_action_id)

func _speed_for(state: StringName) -> float:
	match state:
		STATE_RUN:
			return run_speed
		STATE_CROUCH:
			return crouch_speed
		_:
			return walk_speed

func _dominant_action(input_vector: Vector2) -> StringName:
	if input_vector == Vector2.ZERO:
		return &""
	if absf(input_vector.x) >= absf(input_vector.y):
		return &"move_right" if input_vector.x > 0.0 else &"move_left"
	return &"move_down" if input_vector.y > 0.0 else &"move_up"

func _toggle_hidden() -> void:
	_is_hidden = not _is_hidden
	EventBus.player_hidden_changed.emit(_is_hidden)
	_set_movement_state(STATE_HIDE if _is_hidden else STATE_IDLE, &"hide")

func _sync_flashlight_visual() -> void:
	if _flashlight == null:
		return
	if not _flashlight_enabled:
		_flashlight.energy = _flashlight_float(&"off_energy")
		return
	_flashlight.energy = _flashlight_float(&"low_energy") if is_flashlight_low() else _flashlight_float(&"full_energy")

func _flashlight_float(field: StringName) -> float:
	if flashlight_data == null:
		return 0.0
	return float(flashlight_data.get(field))
