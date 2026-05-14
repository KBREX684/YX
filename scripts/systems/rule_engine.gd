extends Node
class_name RuleEngine

signal rule_triggered(rule_id: String, context: Dictionary)
signal clue_unlocked(clue_id: String)

@export var rules: Array[RuleResource] = []
@export var auto_subscribe_event_bus := true

var _emitted_event_keys: Dictionary = {}


func _ready() -> void:
	if auto_subscribe_event_bus:
		_subscribe_event_bus()


func evaluate(context: Dictionary) -> Array[RuleResource]:
	var triggered: Array[RuleResource] = []
	var seen_rule_ids := {}
	for rule in rules:
		if rule == null or seen_rule_ids.has(rule.id):
			continue
		if _matches_rule(rule, context):
			seen_rule_ids[rule.id] = true
			triggered.append(rule)
			_emit_rule(rule, context)
	return triggered


func clear_event_history() -> void:
	_emitted_event_keys.clear()


func _subscribe_event_bus() -> void:
	if not EventBus.noise_emitted.is_connected(_on_noise_emitted):
		EventBus.noise_emitted.connect(_on_noise_emitted)
	if not EventBus.flashlight_toggled.is_connected(_on_flashlight_toggled):
		EventBus.flashlight_toggled.connect(_on_flashlight_toggled)
	if not EventBus.clue_collected.is_connected(_on_clue_collected):
		EventBus.clue_collected.connect(_on_clue_collected)


func _on_noise_emitted(level: int, position: Vector2, source_action_id: StringName) -> void:
	evaluate({
		"event_type": "noise",
		"noise_level": level,
		"position": position,
		"source_action_id": source_action_id,
	})


func _on_flashlight_toggled(is_on: bool, battery: float) -> void:
	evaluate({
		"event_type": "flashlight",
		"light_is_on": is_on,
		"battery": battery,
	})


func _on_clue_collected(clue_id: String) -> void:
	evaluate({
		"event_type": "clue",
		"clue_id": clue_id,
	})


func _matches_rule(rule: RuleResource, context: Dictionary) -> bool:
	if not _rule_is_visible(rule, context):
		return false
	for condition in rule.trigger_conditions:
		if typeof(condition) != TYPE_DICTIONARY:
			return false
		if not _condition_matches(condition, context):
			return false
	return true


func _rule_is_visible(rule: RuleResource, context: Dictionary) -> bool:
	if rule.clue_unlock_id.strip_edges() == "":
		return true
	return _collection_has(context.get("known_clues", []), rule.clue_unlock_id)


func _condition_matches(condition: Dictionary, context: Dictionary) -> bool:
	match String(condition.get("type", "")):
		"always":
			return true
		"player_action":
			return _context_action(context) == String(condition.get("action", ""))
		"zone":
			return String(context.get("zone_id", "")) == String(condition.get("zone_id", ""))
		"noise_level_min":
			return int(context.get("noise_level", context.get("level", 0))) >= int(condition.get("min", 0))
		"light_state":
			return bool(context.get("light_is_on", false)) == bool(condition.get("is_on", true))
		"has_item":
			return _collection_has(context.get("items", context.get("player_carried_items", [])), condition.get("item_id", ""))
		"flag":
			var key := String(condition.get("key", ""))
			return key != "" and context.has(key) and context[key] == condition.get("value", true)
		"context_equals":
			var key := String(condition.get("key", ""))
			return key != "" and context.has(key) and context[key] == condition.get("value")
		_:
			return false


func _context_action(context: Dictionary) -> String:
	if context.has("source_action_id"):
		return String(context["source_action_id"])
	if context.has("action_id"):
		return String(context["action_id"])
	return String(context.get("action", ""))


func _emit_rule(rule: RuleResource, context: Dictionary) -> void:
	var event_key := _event_key(rule.id, context)
	if event_key != "" and _emitted_event_keys.has(event_key):
		return
	if event_key != "":
		_emitted_event_keys[event_key] = true
	rule_triggered.emit(rule.id, context)
	EventBus.rule_triggered.emit(rule.id, context)
	_emit_effect_outputs(rule.effect)


func _event_key(rule_id: String, context: Dictionary) -> String:
	var event_id := String(context.get("event_id", ""))
	return "" if event_id == "" else "%s:%s" % [rule_id, event_id]


func _emit_effect_outputs(effect: Dictionary) -> void:
	var clue_id := String(effect.get("clue_id", effect.get("unlock_clue_id", "")))
	if clue_id != "":
		clue_unlocked.emit(clue_id)


func _collection_has(collection: Variant, value: Variant) -> bool:
	if typeof(collection) == TYPE_PACKED_STRING_ARRAY:
		return (collection as PackedStringArray).has(String(value))
	if typeof(collection) == TYPE_ARRAY:
		var array := collection as Array
		return array.has(value) or array.has(String(value)) or array.has(StringName(String(value)))
	return false
