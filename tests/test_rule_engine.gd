extends GutTest

const RULE_ENGINE_SCRIPT := "res://scripts/systems/rule_engine.gd"
const DA_ZHI_RULE_FILES := [
	"res://data/rules/da_zhi/rule_da_zhi_corridor_run.tres",
	"res://data/rules/da_zhi/rule_da_zhi_first_manifestation.tres",
	"res://data/rules/da_zhi/rule_da_zhi_broadcast_power_off_weakness.tres",
	"res://data/rules/da_zhi/rule_da_zhi_containment_roster_step.tres",
]
const DA_ZHI_CLUE_RULE_FILES := [
	"res://data/rules/da_zhi/clue_da_zhi_corridor_echo.tres",
	"res://data/rules/da_zhi/clue_da_zhi_broadcast_dependency.tres",
	"res://data/rules/da_zhi/clue_da_zhi_full_roster.tres",
]


func test_rule_engine_script_and_da_zhi_rule_data_exist() -> void:
	assert_true(ResourceLoader.exists(RULE_ENGINE_SCRIPT), "rule_engine.gd should exist.")
	for path in DA_ZHI_RULE_FILES:
		assert_true(ResourceLoader.exists(path), "%s should exist." % path)


func test_single_rule_trigger_emits_event_bus_signal() -> void:
	if not _engine_exists():
		return

	var engine := _make_engine([
		_make_rule("rule_test_run", [
			{"type": "player_action", "action": "run"},
			{"type": "zone", "zone_id": "main_corridor"},
		])
	])
	watch_signals(EventBus)

	var triggered: Array = engine.evaluate({
		"source_action_id": &"run",
		"zone_id": "main_corridor",
	})

	assert_eq(triggered.size(), 1)
	assert_eq(triggered[0].id, "rule_test_run")
	assert_signal_emitted(EventBus, "rule_triggered")


func test_multiple_rules_can_trigger_from_same_context() -> void:
	if not _engine_exists():
		return

	var engine := _make_engine([
		_make_rule("rule_test_run", [{"type": "player_action", "action": "run"}]),
		_make_rule("rule_test_noise", [{"type": "noise_level_min", "min": 3}]),
	])
	var triggered: Array = engine.evaluate({
		"source_action_id": &"run",
		"noise_level": 3,
	})

	assert_eq(triggered.size(), 2)
	assert_eq(_ids(triggered), PackedStringArray(["rule_test_run", "rule_test_noise"]))


func test_unmatched_conditions_do_not_trigger() -> void:
	if not _engine_exists():
		return

	var engine := _make_engine([
		_make_rule("rule_test_run", [{"type": "player_action", "action": "run"}])
	])

	assert_true(engine.evaluate({"source_action_id": &"crouch"}).is_empty())


func test_duplicate_rule_ids_are_deduped_per_evaluation() -> void:
	if not _engine_exists():
		return

	var first := _make_rule("rule_test_duplicate", [{"type": "always"}])
	var second := _make_rule("rule_test_duplicate", [{"type": "always"}])
	var engine := _make_engine([first, second])

	assert_eq(engine.evaluate({}).size(), 1)


func test_event_bus_noise_signal_is_consumed() -> void:
	if not _engine_exists():
		return

	var engine := _make_engine([
		_make_rule("rule_test_noise_run", [
			{"type": "player_action", "action": "run"},
			{"type": "noise_level_min", "min": 3},
		])
	], true)
	var last_rule := [""]
	engine.rule_triggered.connect(func(rule_id: String, _context: Dictionary) -> void: last_rule[0] = rule_id)

	EventBus.noise_emitted.emit(3, Vector2.ZERO, &"run")

	assert_eq(last_rule[0], "rule_test_noise_run")


func test_clue_unlock_signal_emits_from_effect() -> void:
	if not _engine_exists():
		return

	var rule := _make_rule("rule_test_clue", [{"type": "always"}], {
		"type": "clue_unlock",
		"clue_id": "clue_test_rule",
	})
	var engine := _make_engine([rule])
	var unlocked := [""]
	engine.clue_unlocked.connect(func(clue_id: String) -> void: unlocked[0] = clue_id)

	engine.evaluate({})

	assert_eq(unlocked[0], "clue_test_rule")


func test_da_zhi_data_contains_required_rule_types_and_failure_hints() -> void:
	var effect_types := {}
	for path in DA_ZHI_RULE_FILES:
		assert_true(ResourceLoader.exists(path), "%s should exist." % path)
		if not ResourceLoader.exists(path):
			continue
		var rule: Resource = load(path)
		var effect: Dictionary = rule.get("effect")
		effect_types[effect.get("type", "")] = true
		if bool(effect.get("is_critical_failure", false)):
			assert_ne(String(rule.get("learnable_hint")).strip_edges(), "")

	assert_true(effect_types.has("manifestation"))
	assert_true(effect_types.has("weakness_window"))
	assert_true(effect_types.has("containment_step"))


func test_da_zhi_clue_stub_rules_are_ready_for_p3() -> void:
	for path in DA_ZHI_CLUE_RULE_FILES:
		assert_true(ResourceLoader.exists(path), "%s should exist." % path)
		if not ResourceLoader.exists(path):
			continue
		var rule: Resource = load(path)
		var clue_id := String(rule.get("clue_unlock_id"))
		var effect: Dictionary = rule.get("effect")

		assert_string_starts_with(rule.get("id"), "clue_da_zhi_")
		assert_string_starts_with(clue_id, "clue_")
		assert_eq(effect.get("type", ""), "clue_stub")
		assert_eq(effect.get("target_id", ""), "da_zhi")
		assert_eq(effect.get("clue_id", ""), clue_id)
		assert_false(effect.has("dialogic_timeline_id"))
		assert_false(effect.has("note_text"))

	var profile: Resource = load("res://data/monsters/da_zhi.tres")
	for path in DA_ZHI_CLUE_RULE_FILES:
		var rule: Resource = load(path)
		assert_has(profile.get("rule_ids"), rule.get("id"))


func _engine_exists() -> bool:
	assert_true(ResourceLoader.exists(RULE_ENGINE_SCRIPT), "rule_engine.gd should exist.")
	return ResourceLoader.exists(RULE_ENGINE_SCRIPT)


func _make_engine(rules: Array, auto_subscribe: bool = false) -> Node:
	var engine: Node = load(RULE_ENGINE_SCRIPT).new()
	engine.auto_subscribe_event_bus = auto_subscribe
	engine.rules.assign(rules)
	add_child_autofree(engine)
	return engine


func _make_rule(id: String, conditions: Array, effect: Dictionary = {"type": "test"}) -> RuleResource:
	var rule := RuleResource.new()
	rule.id = id
	rule.trigger_conditions = conditions
	rule.effect = effect
	return rule


func _ids(rules: Array) -> PackedStringArray:
	var ids := PackedStringArray()
	for rule in rules:
		ids.append(rule.id)
	return ids
