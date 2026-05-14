extends Node

enum SceneId { MAIN_MENU, BASE, DUNGEON, SETTLEMENT }

const SCENE_NAMES := ["main_menu", "base", "dungeon", "settlement"]
const DEATH_FEEDBACK_RESOLVER := "res://scripts/systems/death_feedback_resolver.gd"

var current_scene: SceneId = SceneId.MAIN_MENU
var current_dungeon_id: String = ""
var carried_origin_id: String = ""
var contamination: float = 0.0
var known_clue_ids: PackedStringArray = PackedStringArray()
var base_respawn_scene_path := "res://scenes/base/base_placeholder.tscn"
var enable_scene_change_on_respawn := true
var dungeon_loot_return_ratio_on_death := 0.0
var missing_death_hint_rule_ids: PackedStringArray = PackedStringArray()

var _last_death_feedback: Dictionary = {}
var _pending_death_context: Dictionary = {}

func _ready() -> void:
	if not EventBus.player_died.is_connected(_on_player_died):
		EventBus.player_died.connect(_on_player_died)

func record_clue(clue_id: String) -> bool:
	var normalized := clue_id.strip_edges()
	if normalized == "" or known_clue_ids.has(normalized):
		return false
	known_clue_ids.append(normalized)
	return true

func knows_clue(clue_id: String) -> bool:
	return known_clue_ids.has(clue_id.strip_edges())

func clear_known_clues() -> void:
	known_clue_ids.clear()

func set_known_clues(clue_ids: PackedStringArray) -> void:
	known_clue_ids.clear()
	for clue_id in clue_ids:
		record_clue(clue_id)

func goto_scene(target: SceneId) -> void:
	var from_id := _scene_id_to_string(current_scene)
	current_scene = target
	EventBus.scene_changed.emit(from_id, _scene_id_to_string(current_scene))

func snapshot_loadout() -> Dictionary:
	return {"current_dungeon_id": current_dungeon_id, "carried_origin_id": carried_origin_id}

func apply_dungeon_loss(payload: Dictionary) -> Dictionary:
	var carried := maxi(int(payload.get("carried_in_total", 0)), 0)
	var looted := maxi(int(payload.get("looted_total", payload.get("pickup_total", 0))), 0)
	var returned := maxi(int(round(float(looted) * dungeon_loot_return_ratio_on_death)), 0)
	return {
		"carried_in_lost": carried,
		"looted_total": looted,
		"looted_returned": returned,
		"looted_lost": maxi(looted - returned, 0),
		"return_ratio": dungeon_loot_return_ratio_on_death,
	}

func set_pending_death_context(payload: Dictionary) -> void:
	_pending_death_context = payload.duplicate(true)

func clear_respawn_state() -> void:
	_last_death_feedback.clear()
	_pending_death_context.clear()
	missing_death_hint_rule_ids.clear()

func get_last_death_feedback() -> Dictionary:
	return _last_death_feedback.duplicate(true)

func respawn_at_base(payload: Dictionary = {}, change_scene: bool = enable_scene_change_on_respawn) -> Dictionary:
	var from_id := _scene_id_to_string(current_scene)
	_last_death_feedback = _resolve_death_feedback(payload)
	_last_death_feedback["loss"] = apply_dungeon_loss(payload)
	_last_death_feedback["respawn_scene_path"] = base_respawn_scene_path
	current_scene = SceneId.BASE
	current_dungeon_id = ""
	clear_known_clues()
	EventBus.scene_changed.emit(from_id, _scene_id_to_string(current_scene))
	if change_scene and ResourceLoader.exists(base_respawn_scene_path):
		get_tree().change_scene_to_file(base_respawn_scene_path)
	return get_last_death_feedback()

func _on_player_died() -> void:
	var payload := _pending_death_context.duplicate(true)
	_pending_death_context.clear()
	respawn_at_base(payload, enable_scene_change_on_respawn)

func _resolve_death_feedback(payload: Dictionary) -> Dictionary:
	var feedback: Dictionary = load(DEATH_FEEDBACK_RESOLVER).new().resolve(payload)
	var rule_id := String(feedback.get("source_rule_id", ""))
	if bool(feedback.get("is_fallback", false)) and rule_id != "" and not missing_death_hint_rule_ids.has(rule_id):
		missing_death_hint_rule_ids.append(rule_id)
	return feedback

func _scene_id_to_string(scene_id: SceneId) -> String:
	return SCENE_NAMES[scene_id] if scene_id >= 0 and scene_id < SCENE_NAMES.size() else "unknown"
