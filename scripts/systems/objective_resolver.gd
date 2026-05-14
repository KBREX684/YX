extends Node
class_name ObjectiveResolver

signal containment_step_completed(step_id: String, sequence_index: int)
signal objective_completed(objective_type: int, payload: Dictionary)

const OBJECTIVE_ESCAPE := 0
const OBJECTIVE_KILL := 1
const OBJECTIVE_CONTAIN := 2
const OBJECTIVE_MISCONTAIN := 3

@export var auto_subscribe_event_bus := true

var _completed_steps := PackedStringArray()
var _completed_objectives: Dictionary = {}


func _ready() -> void:
	add_to_group("objective_resolver")
	if auto_subscribe_event_bus:
		_subscribe_event_bus()


func _exit_tree() -> void:
	if EventBus.rule_triggered.is_connected(_on_rule_triggered):
		EventBus.rule_triggered.disconnect(_on_rule_triggered)


func get_completed_steps() -> PackedStringArray:
	var copy := PackedStringArray()
	copy.append_array(_completed_steps)
	return copy


func is_step_completed(step_id: String) -> bool:
	return _completed_steps.has(step_id)


func has_completed_objective(objective_type: int) -> bool:
	return _completed_objectives.has(objective_type)


func get_objective_payload(objective_type: int) -> Dictionary:
	return _completed_objectives.get(objective_type, {}).duplicate(true)


func clear() -> void:
	_completed_steps.clear()
	_completed_objectives.clear()


func _subscribe_event_bus() -> void:
	if not EventBus.rule_triggered.is_connected(_on_rule_triggered):
		EventBus.rule_triggered.connect(_on_rule_triggered)


func _on_rule_triggered(rule_id: String, context: Dictionary) -> void:
	var effect_value: Variant = context.get("rule_effect", {})
	if typeof(effect_value) != TYPE_DICTIONARY:
		return
	var effect := effect_value as Dictionary
	match String(effect.get("type", "")):
		"containment_step":
			_apply_containment_step(effect)
		"objective_complete":
			_apply_objective_complete(rule_id, effect)


func _apply_containment_step(effect: Dictionary) -> void:
	var step_id := String(effect.get("step_id", ""))
	if step_id == "" or _completed_steps.has(step_id):
		return
	_completed_steps.append(step_id)
	containment_step_completed.emit(step_id, int(effect.get("sequence_index", 0)))


func _apply_objective_complete(rule_id: String, effect: Dictionary) -> void:
	var objective_type := int(effect.get("objective_type", _objective_type_from_outcome(String(effect.get("outcome", "")))))
	if objective_type < 0 or _completed_objectives.has(objective_type):
		return
	var payload := effect.duplicate(true)
	payload["rule_id"] = rule_id
	payload["objective_type"] = objective_type
	if not payload.has("monster_id") and payload.has("target_id"):
		payload["monster_id"] = String(payload["target_id"])
	_completed_objectives[objective_type] = payload.duplicate(true)
	objective_completed.emit(objective_type, payload)
	EventBus.objective_completed.emit(objective_type, payload)


func _objective_type_from_outcome(outcome: String) -> int:
	match outcome:
		"escape":
			return OBJECTIVE_ESCAPE
		"kill":
			return OBJECTIVE_KILL
		"contain":
			return OBJECTIVE_CONTAIN
		"miscontain":
			return OBJECTIVE_MISCONTAIN
		_:
			return -1
