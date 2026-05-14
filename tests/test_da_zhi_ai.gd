extends GutTest

const DA_ZHI_SCENE_PATH := "res://scenes/monster/da_zhi.tscn"
const DA_ZHI_SCRIPT_PATH := "res://scripts/monster/da_zhi.gd"
const DA_ZHI_STATE_SCRIPT_PATH := "res://scripts/monster/states/da_zhi_limbo_state.gd"
const DA_ZHI_PROFILE_PATH := "res://data/monsters/da_zhi.tres"
const RULE_ENGINE_SCRIPT := "res://scripts/systems/rule_engine.gd"
const RUN_RULE_PATH := "res://data/rules/da_zhi/rule_da_zhi_corridor_run.tres"
const MANIFEST_RULE_PATH := "res://data/rules/da_zhi/rule_da_zhi_first_manifestation.tres"


func test_da_zhi_required_files_exist() -> void:
	for path in [DA_ZHI_SCENE_PATH, DA_ZHI_SCRIPT_PATH, DA_ZHI_STATE_SCRIPT_PATH, DA_ZHI_PROFILE_PATH]:
		assert_true(ResourceLoader.exists(path), "%s should exist." % path)


func test_da_zhi_scene_has_runtime_nodes_and_placeholder_label() -> void:
	if not ResourceLoader.exists(DA_ZHI_SCENE_PATH):
		assert_true(false, "da_zhi.tscn should exist.")
		return

	var da_zhi := _instantiate_da_zhi()
	assert_true(da_zhi is CharacterBody2D)
	for path in ["Visual", "CollisionShape2D", "NavigationAgent2D", "StateMachine"]:
		assert_not_null(da_zhi.get_node_or_null(path), "Expected node %s." % path)
	assert_string_contains(da_zhi.get_node("PlaceholderAssetLabel").text, "占位")


func test_da_zhi_profile_references_rule_resources() -> void:
	if not ResourceLoader.exists(DA_ZHI_PROFILE_PATH):
		assert_true(false, "da_zhi.tres should exist.")
		return

	var profile: Resource = load(DA_ZHI_PROFILE_PATH)
	assert_eq(profile.get("id"), "da_zhi")
	assert_has(profile.get("rule_ids"), "rule_da_zhi_corridor_run")
	assert_has(profile.get("rule_ids"), "rule_da_zhi_first_manifestation")
	assert_eq(profile.get("weakness_rule_id"), "rule_da_zhi_broadcast_power_off_weakness")
	assert_has(profile.get("containment_rule_ids"), "rule_da_zhi_containment_roster_step")


func test_da_zhi_starts_dormant_and_not_manifested() -> void:
	if not ResourceLoader.exists(DA_ZHI_SCENE_PATH):
		return

	var da_zhi := _instantiate_da_zhi()
	assert_eq(da_zhi.get_phase(), &"dormant")
	assert_false(da_zhi.is_manifested())
	assert_lte(da_zhi.get_node("Visual").modulate.a, 0.05)


func test_noise_rule_changes_da_zhi_phase_but_walk_does_not() -> void:
	if not _runtime_files_exist():
		return

	var da_zhi := _instantiate_da_zhi()
	var engine := _make_engine([load(RUN_RULE_PATH)])
	engine.evaluate({
		"source_action_id": &"walk",
		"zone_id": "main_corridor",
		"noise_level": 2,
	})
	assert_eq(da_zhi.get_phase(), &"dormant")

	engine.evaluate({
		"source_action_id": &"run",
		"zone_id": "main_corridor",
		"noise_level": 3,
	})
	assert_eq(da_zhi.get_phase(), &"search")


func test_manifestation_rule_reveals_da_zhi_without_random_teleport() -> void:
	if not _runtime_files_exist():
		return

	var da_zhi := _instantiate_da_zhi() as CharacterBody2D
	var before: Vector2 = da_zhi.global_position
	var engine := _make_engine([load(MANIFEST_RULE_PATH)])
	engine.evaluate({
		"entered_main_corridor": true,
		"first_visit": true,
	})

	assert_true(da_zhi.is_manifested())
	assert_almost_eq(da_zhi.get_node("Visual").modulate.a, 0.3, 0.01)
	assert_eq(da_zhi.global_position, before)


func test_da_zhi_script_stays_small_and_rule_id_agnostic() -> void:
	assert_true(ResourceLoader.exists(DA_ZHI_SCRIPT_PATH), "da_zhi.gd should exist.")
	if not ResourceLoader.exists(DA_ZHI_SCRIPT_PATH):
		return

	var source := FileAccess.get_file_as_string(DA_ZHI_SCRIPT_PATH)
	assert_lte(source.split("\n").size(), 200)
	assert_false(source.contains("rule_da_zhi_"))
	assert_false(source.contains("rand"))


func _runtime_files_exist() -> bool:
	for path in [DA_ZHI_SCENE_PATH, RULE_ENGINE_SCRIPT, RUN_RULE_PATH, MANIFEST_RULE_PATH]:
		if not ResourceLoader.exists(path):
			assert_true(false, "%s should exist." % path)
			return false
	return true


func _instantiate_da_zhi() -> Node:
	var scene: PackedScene = load(DA_ZHI_SCENE_PATH)
	var da_zhi := scene.instantiate()
	add_child_autofree(da_zhi)
	return da_zhi


func _make_engine(rules: Array) -> Node:
	var engine: Node = load(RULE_ENGINE_SCRIPT).new()
	engine.auto_subscribe_event_bus = false
	engine.rules.assign(rules)
	add_child_autofree(engine)
	return engine
