extends GutTest

const OBJECTIVE_RESOLVER_SCRIPT := "res://scripts/systems/objective_resolver.gd"
const RULE_ENGINE_SCRIPT := "res://scripts/systems/rule_engine.gd"
const SCHOOL_SCENE_PATH := "res://scenes/dungeon/abandoned_school.tscn"
const DA_ZHI_PROFILE_PATH := "res://data/monsters/da_zhi.tres"

const WEAKNESS_RULE_PATH := "res://data/rules/da_zhi/weakness.tres"
const CONTAINMENT_STEP_1_PATH := "res://data/rules/da_zhi/containment_step_1.tres"
const CONTAINMENT_STEP_2_PATH := "res://data/rules/da_zhi/containment_step_2.tres"
const CONTAINMENT_STEP_3_PATH := "res://data/rules/da_zhi/containment_step_3.tres"
const CONTAINMENT_FAILURE_PATH := "res://data/rules/da_zhi/containment_failure.tres"

const OBJECTIVE_KILL := 1
const OBJECTIVE_CONTAIN := 2
const OBJECTIVE_MISCONTAIN := 3


func test_objective_execution_contract_files_exist() -> void:
	assert_true(EventBus.has_signal("objective_completed"), "EventBus should expose objective_completed(type, payload).")
	assert_true(ResourceLoader.exists(OBJECTIVE_RESOLVER_SCRIPT), "ObjectiveResolver should exist.")
	for path in [
		WEAKNESS_RULE_PATH,
		CONTAINMENT_STEP_1_PATH,
		CONTAINMENT_STEP_2_PATH,
		CONTAINMENT_STEP_3_PATH,
		CONTAINMENT_FAILURE_PATH,
	]:
		assert_true(ResourceLoader.exists(path), "%s should exist." % path)


func test_weakness_rule_requires_clue_items_window_and_phase() -> void:
	if not _runtime_ready([WEAKNESS_RULE_PATH]):
		return

	var engine := _make_engine([load(WEAKNESS_RULE_PATH)])
	assert_true(engine.evaluate(_kill_context(false, true, true)).is_empty())
	assert_true(engine.evaluate(_kill_context(true, false, true)).is_empty())
	assert_true(engine.evaluate(_kill_context(true, true, false)).is_empty())

	var triggered: Array = engine.evaluate(_kill_context(true, true, true))
	assert_eq(triggered.size(), 1)
	var effect: Dictionary = triggered[0].get("effect")
	assert_eq(effect.get("type"), "objective_complete")
	assert_eq(int(effect.get("objective_type")), OBJECTIVE_KILL)


func test_objective_resolver_emits_kill_completion_from_rule_effect() -> void:
	if not _runtime_ready([WEAKNESS_RULE_PATH]):
		return

	var resolver := _make_resolver()
	var completed := [-1, {}]
	EventBus.connect("objective_completed", func(objective_type: int, payload: Dictionary) -> void:
		completed[0] = objective_type
		completed[1] = payload
	)

	var engine := _make_engine([load(WEAKNESS_RULE_PATH)])
	engine.evaluate(_kill_context(true, true, true))

	assert_eq(completed[0], OBJECTIVE_KILL)
	assert_eq(completed[1].get("monster_id"), "da_zhi")
	assert_eq(completed[1].get("origin_stability"), "low")
	assert_true(resolver.has_completed_objective(OBJECTIVE_KILL))


func test_containment_steps_require_sequence_and_emit_containment() -> void:
	if not _runtime_ready([CONTAINMENT_STEP_1_PATH, CONTAINMENT_STEP_2_PATH, CONTAINMENT_STEP_3_PATH]):
		return

	var resolver := _make_resolver()
	var engine := _make_engine([
		load(CONTAINMENT_STEP_1_PATH),
		load(CONTAINMENT_STEP_2_PATH),
		load(CONTAINMENT_STEP_3_PATH),
	])
	var completed := [-1]
	EventBus.connect("objective_completed", func(objective_type: int, _payload: Dictionary) -> void:
		completed[0] = objective_type
	)

	assert_true(engine.evaluate(_contain_step_2_context(PackedStringArray())).is_empty())
	assert_true(engine.evaluate(_contain_step_3_context(PackedStringArray(["roster_confirmation"]))).is_empty())

	assert_eq(engine.evaluate(_contain_step_1_context()).size(), 1)
	assert_true(resolver.is_step_completed("roster_confirmation"))
	assert_eq(engine.evaluate(_contain_step_2_context(resolver.get_completed_steps())).size(), 1)
	assert_true(resolver.is_step_completed("sound_seal"))
	assert_eq(engine.evaluate(_contain_step_3_context(resolver.get_completed_steps())).size(), 1)

	assert_eq(completed[0], OBJECTIVE_CONTAIN)
	assert_true(resolver.has_completed_objective(OBJECTIVE_CONTAIN))


func test_wrong_anchor_order_emits_miscontainment() -> void:
	if not _runtime_ready([CONTAINMENT_FAILURE_PATH]):
		return

	var resolver := _make_resolver()
	var completed := [-1, {}]
	EventBus.connect("objective_completed", func(objective_type: int, payload: Dictionary) -> void:
		completed[0] = objective_type
		completed[1] = payload
	)
	var engine := _make_engine([load(CONTAINMENT_FAILURE_PATH)])

	var triggered: Array = engine.evaluate({
		"zone_id": "ritual_room",
		"source_action_id": &"place_anchors",
		"known_clues": PackedStringArray(["clue_silence_taboo"]),
		"ritual_order_correct": false,
	})

	assert_eq(triggered.size(), 1)
	assert_eq(completed[0], OBJECTIVE_MISCONTAIN)
	assert_eq(completed[1].get("failure_level"), "heavy")
	assert_true(resolver.has_completed_objective(OBJECTIVE_MISCONTAIN))


func test_da_zhi_profile_references_execution_rules() -> void:
	assert_true(ResourceLoader.exists(DA_ZHI_PROFILE_PATH), "da_zhi.tres should exist.")
	if not ResourceLoader.exists(DA_ZHI_PROFILE_PATH):
		return

	var profile: Resource = load(DA_ZHI_PROFILE_PATH)
	var rule_ids: PackedStringArray = profile.get("rule_ids")
	for rule_id in [
		"rule_da_zhi_weakness_execute",
		"rule_da_zhi_containment_step_1",
		"rule_da_zhi_containment_step_2",
		"rule_da_zhi_containment_step_3",
		"rule_da_zhi_containment_failure",
	]:
		assert_has(rule_ids, rule_id)
	assert_has(profile.get("containment_rule_ids"), "rule_da_zhi_containment_step_1")
	assert_has(profile.get("containment_rule_ids"), "rule_da_zhi_containment_step_2")
	assert_has(profile.get("containment_rule_ids"), "rule_da_zhi_containment_step_3")


func test_abandoned_school_has_objective_resolver_and_ritual_triggers() -> void:
	if not ResourceLoader.exists(SCHOOL_SCENE_PATH):
		assert_true(false, "abandoned_school.tscn should exist.")
		return

	var school := _instantiate_scene(SCHOOL_SCENE_PATH)
	assert_not_null(school.get_node_or_null("ObjectiveResolver"))
	var triggers := school.get_node_or_null("RitualTriggers")
	assert_not_null(triggers)
	if triggers == null:
		return
	for node_name in ["RosterStep", "SoundSealStep", "AnchorStep", "FailureStep"]:
		var trigger := triggers.get_node_or_null(node_name)
		assert_not_null(trigger)
		if trigger != null:
			assert_ne(String(trigger.get("placeholder_asset_note")).strip_edges(), "")
			assert_not_null(trigger.get_node_or_null("PlaceholderAssetLabel"))


func test_objective_resolver_stays_small_and_rule_id_agnostic() -> void:
	assert_true(ResourceLoader.exists(OBJECTIVE_RESOLVER_SCRIPT), "objective_resolver.gd should exist.")
	if not ResourceLoader.exists(OBJECTIVE_RESOLVER_SCRIPT):
		return
	var source := FileAccess.get_file_as_string(OBJECTIVE_RESOLVER_SCRIPT)
	assert_lte(source.split("\n").size(), 220)
	assert_false(source.contains("rule_da_zhi_"))


func _runtime_ready(rule_paths: Array) -> bool:
	var paths := [OBJECTIVE_RESOLVER_SCRIPT, RULE_ENGINE_SCRIPT]
	paths.append_array(rule_paths)
	for path in paths:
		if not ResourceLoader.exists(path):
			assert_true(false, "%s should exist." % path)
			return false
	if not EventBus.has_signal("objective_completed"):
		assert_true(false, "EventBus.objective_completed should exist.")
		return false
	return true


func _make_engine(rules: Array) -> Node:
	var engine: Node = load(RULE_ENGINE_SCRIPT).new()
	engine.auto_subscribe_event_bus = false
	engine.rules.assign(rules)
	add_child_autofree(engine)
	return engine


func _make_resolver() -> Node:
	var resolver: Node = load(OBJECTIVE_RESOLVER_SCRIPT).new()
	add_child_autofree(resolver)
	return resolver


func _kill_context(has_clue: bool, has_item: bool, has_window: bool) -> Dictionary:
	return {
		"zone_id": "storage_entrance",
		"source_action_id": &"lock_warehouse_chain",
		"monster_phase": "search",
		"known_clues": PackedStringArray(["clue_broadcast_dependency"] if has_clue else []),
		"items": PackedStringArray(["item_noise_bait"] if has_item else []),
		"broadcast_silence_active": has_window,
		"warehouse_chain_locked": true,
	}


func _contain_step_1_context() -> Dictionary:
	return {
		"zone_id": "records_room",
		"source_action_id": &"read_roster",
		"known_clues": PackedStringArray(["clue_full_roster"]),
		"roster_complete": true,
	}


func _contain_step_2_context(completed_steps: PackedStringArray) -> Dictionary:
	return {
		"zone_id": "broadcast_room",
		"source_action_id": &"play_tape",
		"known_clues": PackedStringArray(["clue_ritual_cord_left"]),
		"items": PackedStringArray(["item_ritual_tape"]),
		"light_is_on": false,
		"completed_steps": completed_steps,
	}


func _contain_step_3_context(completed_steps: PackedStringArray) -> Dictionary:
	return {
		"zone_id": "ritual_room",
		"source_action_id": &"place_anchors",
		"known_clues": PackedStringArray(["clue_ritual_cord_right", "clue_silence_taboo"]),
		"items": PackedStringArray([
			"item_school_badge",
			"item_student_photo",
			"item_duty_roster",
			"item_last_broadcast_script",
		]),
		"completed_steps": completed_steps,
		"ritual_order_correct": true,
	}


func _instantiate_scene(path: String) -> Node:
	var scene: PackedScene = load(path)
	var node := scene.instantiate()
	add_child_autofree(node)
	return node
