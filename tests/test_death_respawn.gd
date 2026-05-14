extends GutTest

const BASE_SCENE_PATH := "res://scenes/base/base_placeholder.tscn"
const BASE_SCRIPT_PATH := "res://scripts/base/base_placeholder.gd"
const DEATH_FEEDBACK_RESOLVER_SCRIPT := "res://scripts/systems/death_feedback_resolver.gd"
const CORRIDOR_RULE_ID := "rule_da_zhi_corridor_run"


func before_each() -> void:
	if _object_has_property(GameState, "enable_scene_change_on_respawn"):
		GameState.enable_scene_change_on_respawn = false
	GameState.current_scene = GameState.SceneId.DUNGEON
	GameState.current_dungeon_id = "abandoned_school"
	GameState.clear_known_clues()
	if GameState.has_method("clear_respawn_state"):
		GameState.clear_respawn_state()


func test_death_respawn_contract_files_and_methods_exist() -> void:
	assert_true(ResourceLoader.exists(BASE_SCENE_PATH), "base_placeholder.tscn should exist.")
	assert_true(ResourceLoader.exists(BASE_SCRIPT_PATH), "base_placeholder.gd should exist.")
	assert_true(ResourceLoader.exists(DEATH_FEEDBACK_RESOLVER_SCRIPT), "DeathFeedbackResolver should exist.")
	assert_true(EventBus.has_signal("player_died"), "EventBus should expose player_died.")
	assert_true(EventBus.has_signal("scene_changed"), "EventBus should expose scene_changed(from, to).")
	assert_true(GameState.has_method("respawn_at_base"), "GameState should respawn at base.")
	assert_true(GameState.has_method("get_last_death_feedback"), "GameState should expose last death feedback.")
	assert_true(_object_has_property(GameState, "enable_scene_change_on_respawn"), "GameState should allow tests to disable scene changes.")


func test_respawn_at_base_resets_dungeon_state_and_emits_scene_change() -> void:
	if not _game_state_ready():
		return

	GameState.record_clue("clue_corridor_echo")
	var scene_event := [{"from": "", "to": ""}]
	EventBus.scene_changed.connect(func(from_id: String, to_id: String) -> void:
		scene_event[0] = {"from": from_id, "to": to_id}
	, CONNECT_ONE_SHOT)

	var feedback: Dictionary = GameState.respawn_at_base({
		"rule_id": CORRIDOR_RULE_ID,
		"carried_in_total": 5,
		"looted_total": 10,
	}, false)

	assert_eq(GameState.current_scene, GameState.SceneId.BASE)
	assert_eq(GameState.current_dungeon_id, "")
	assert_false(GameState.knows_clue("clue_corridor_echo"))
	assert_eq(scene_event[0].get("from"), "dungeon")
	assert_eq(scene_event[0].get("to"), "base")
	assert_eq(int(feedback.get("loss", {}).get("carried_in_lost")), 5)
	assert_eq(int(feedback.get("loss", {}).get("looted_returned")), 0)


func test_death_feedback_resolves_rule_learnable_hint() -> void:
	if not _game_state_ready():
		return

	var feedback: Dictionary = GameState.respawn_at_base({"rule_id": CORRIDOR_RULE_ID}, false)

	assert_eq(feedback.get("source_rule_id"), CORRIDOR_RULE_ID)
	assert_false(bool(feedback.get("is_fallback")))
	assert_ne(String(feedback.get("learnable_hint")).strip_edges(), "")


func test_missing_rule_uses_fallback_and_records_debug_id() -> void:
	if not _game_state_ready():
		return

	var feedback: Dictionary = GameState.respawn_at_base({"rule_id": "rule_missing_for_test"}, false)

	assert_true(bool(feedback.get("is_fallback")))
	assert_true(GameState.missing_death_hint_rule_ids.has("rule_missing_for_test"))
	assert_string_contains(String(feedback.get("learnable_hint")), "未知")


func test_event_bus_player_died_triggers_respawn_without_scene_change_when_disabled() -> void:
	if not _game_state_ready():
		return

	GameState.set_pending_death_context({"rule_id": CORRIDOR_RULE_ID})
	EventBus.player_died.emit()

	assert_eq(GameState.current_scene, GameState.SceneId.BASE)
	assert_eq(GameState.get_last_death_feedback().get("source_rule_id"), CORRIDOR_RULE_ID)


func test_base_placeholder_scene_displays_death_feedback_and_asset_notes() -> void:
	if not ResourceLoader.exists(BASE_SCENE_PATH):
		assert_true(false, "base_placeholder.tscn should exist.")
		return

	GameState.respawn_at_base({"rule_id": CORRIDOR_RULE_ID}, false)
	var base := _instantiate_scene(BASE_SCENE_PATH)

	assert_ne(String(base.get("placeholder_asset_note")).strip_edges(), "")
	assert_not_null(base.get_node_or_null("PlaceholderAssetLabel"))
	assert_string_contains(_label_text(base, "CanvasLayer/DeathFeedbackPanel/Margin/Content/HintLabel"), String(GameState.get_last_death_feedback().get("learnable_hint")))
	assert_string_contains(_label_text(base, "CanvasLayer/DeathFeedbackPanel/Margin/Content/LossLabel"), "0")


func _game_state_ready() -> bool:
	var ready := true
	for method_name in ["respawn_at_base", "set_pending_death_context", "clear_respawn_state", "get_last_death_feedback"]:
		if not GameState.has_method(method_name):
			assert_true(false, "GameState.%s should exist." % method_name)
			ready = false
	return ready


func _instantiate_scene(path: String) -> Node:
	var scene: PackedScene = load(path)
	var node := scene.instantiate()
	add_child_autofree(node)
	return node


func _label_text(root: Node, node_path: String) -> String:
	var label := root.get_node_or_null(node_path)
	assert_not_null(label, "%s should exist." % node_path)
	return "" if label == null else String(label.text)


func _object_has_property(object: Object, property_name: String) -> bool:
	for property in object.get_property_list():
		if String(property.get("name")) == property_name:
			return true
	return false
