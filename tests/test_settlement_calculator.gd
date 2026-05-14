extends GutTest

const SETTLEMENT_CALCULATOR_SCRIPT := "res://scripts/systems/settlement_calculator.gd"
const SETTLEMENT_PAYOFF_RESOURCE_SCRIPT := "res://scripts/systems/resources/settlement_payoff_resource.gd"
const SETTLEMENT_PAYOFF_TABLE := "res://data/settlement_payoffs.tres"
const SETTLEMENT_SCREEN_SCENE := "res://scenes/ui/settlement_screen.tscn"
const SCHOOL_SCENE := "res://scenes/dungeon/abandoned_school.tscn"

const OBJECTIVE_ESCAPE := 0
const OBJECTIVE_KILL := 1
const OBJECTIVE_CONTAIN := 2
const OBJECTIVE_MISCONTAIN := 3


func test_settlement_contract_files_and_event_signal_exist() -> void:
	assert_true(EventBus.has_signal("settlement_ready"), "EventBus should expose settlement_ready(payload).")
	assert_true(ResourceLoader.exists(SETTLEMENT_CALCULATOR_SCRIPT), "SettlementCalculator should exist.")
	assert_true(ResourceLoader.exists(SETTLEMENT_PAYOFF_RESOURCE_SCRIPT), "SettlementPayoffResource should exist.")
	assert_true(ResourceLoader.exists(SETTLEMENT_PAYOFF_TABLE), "settlement_payoffs.tres should exist.")
	assert_true(ResourceLoader.exists(SETTLEMENT_SCREEN_SCENE), "settlement_screen.tscn should exist.")


func test_four_completion_routes_have_distinct_three_axis_rewards() -> void:
	if not _calculator_ready():
		return

	var calculator := _make_calculator(false)
	var pickups := [
		_pickup("survival", 10),
		_pickup("growth", 6),
		_pickup("intel", 4),
	]

	var escape: Dictionary = calculator.calculate(_settlement_input(OBJECTIVE_ESCAPE, pickups, 80))
	var kill: Dictionary = calculator.calculate(_settlement_input(OBJECTIVE_KILL, pickups, 80, {
		"origin_quality": "medium",
		"origin_stability": "low",
	}))
	var contain: Dictionary = calculator.calculate(_settlement_input(OBJECTIVE_CONTAIN, pickups, 80, {
		"origin_quality": "high",
		"origin_stability": "stable",
	}))
	var miscontain: Dictionary = calculator.calculate(_settlement_input(OBJECTIVE_MISCONTAIN, pickups, 80, {
		"failure_level": "heavy",
	}))

	assert_eq(escape.get("settlement_type"), "escape")
	assert_eq(kill.get("settlement_type"), "kill")
	assert_eq(contain.get("settlement_type"), "contain")
	assert_eq(miscontain.get("settlement_type"), "miscontain")

	assert_true(_resource_total(escape) > _resource_total(kill))
	assert_true(_resource_total(kill) > _resource_total(contain))
	assert_true(_origin_rank(contain) > _origin_rank(kill))
	assert_true(_origin_rank(kill) > _origin_rank(escape))
	assert_true(_archive_entries(contain) > _archive_entries(kill))
	assert_true(_archive_entries(kill) > _archive_entries(escape))


func test_miscontainment_deducts_placeholder_base_resources_and_flags_invasion() -> void:
	if not _calculator_ready():
		return

	var calculator := _make_calculator(false)
	var result: Dictionary = calculator.calculate(_settlement_input(OBJECTIVE_MISCONTAIN, [_pickup("survival", 8)], 50, {
		"failure_level": "heavy",
		"origin_quality": "unstable",
		"origin_stability": "volatile",
	}, 100))

	var delta: Dictionary = result.get("base_resource_delta", {})
	var invasion: Dictionary = result.get("base_invasion_trigger", {})
	assert_eq(result.get("settlement_type"), "miscontain")
	assert_eq(int(delta.get("lost")), 15)
	assert_eq(int(delta.get("placeholder_materials")), -15)
	assert_almost_eq(float(invasion.get("chance")), 0.6, 0.001)
	assert_true(bool(invasion.get("enabled")))


func test_hp_zero_and_empty_pickups_are_safe_boundaries() -> void:
	if not _calculator_ready():
		return

	var calculator := _make_calculator(false)
	var result: Dictionary = calculator.calculate(_settlement_input(OBJECTIVE_ESCAPE, [], 0))
	var resources: Dictionary = result.get("resource_summary", {})

	assert_eq(result.get("settlement_type"), "escape")
	assert_false(bool(result.get("survived")))
	assert_eq(int(resources.get("total_raw")), 0)
	assert_eq(int(resources.get("total_awarded")), 0)
	assert_eq(int(resources.get("lost")), 0)


func test_calculator_consumes_objective_completed_and_emits_settlement_ready() -> void:
	if not _calculator_ready():
		return

	var calculator := _make_calculator(true)
	var emitted := [{}]
	EventBus.settlement_ready.connect(func(payload: Dictionary) -> void:
		emitted[0] = payload
	, CONNECT_ONE_SHOT)

	calculator.set_run_context({
		"hp_remaining": 42,
		"pickup_list": [_pickup("puzzle", 5)],
		"triggered_rules": PackedStringArray(["rule_da_zhi_weakness_execute"]),
		"base_storage_total": 40,
	})
	EventBus.objective_completed.emit(OBJECTIVE_KILL, {
		"monster_id": "da_zhi",
		"origin_quality": "medium",
		"origin_stability": "low",
	})

	assert_eq(emitted[0].get("settlement_type"), "kill")
	assert_eq(calculator.get_last_settlement().get("settlement_type"), "kill")
	assert_eq(_origin_rank(emitted[0]), 1)


func test_settlement_screen_displays_numeric_summary() -> void:
	if not _screen_ready():
		return

	var screen := _instantiate_scene(SETTLEMENT_SCREEN_SCENE)
	screen.display_settlement({
		"settlement_type": "contain",
		"resource_summary": {
			"survival": 2,
			"puzzle": 3,
			"growth": 4,
			"intel": 5,
			"total_awarded": 14,
			"lost": 1,
		},
		"origin_output": {
			"quality": "high",
			"stability": "stable",
			"route_affinity": "containment",
		},
		"archive_update": {
			"entries_added": 4,
			"completion_percent": 80,
		},
		"base_resource_delta": {
			"placeholder_materials": -15,
			"lost": 15,
		},
	})

	assert_string_contains(_label_text(screen, "Margin/Content/CompletionTypeLabel"), "contain")
	assert_string_contains(_label_text(screen, "Margin/Content/ResourceValueLabel"), "14")
	assert_string_contains(_label_text(screen, "Margin/Content/OriginValueLabel"), "high")
	assert_string_contains(_label_text(screen, "Margin/Content/ArchiveValueLabel"), "4")
	assert_string_contains(_label_text(screen, "Margin/Content/BaseDeltaLabel"), "-15")


func test_payoff_table_is_inspector_editable_resource_data() -> void:
	if not ResourceLoader.exists(SETTLEMENT_PAYOFF_TABLE):
		assert_true(false, "settlement_payoffs.tres should exist.")
		return

	var payoffs: Resource = load(SETTLEMENT_PAYOFF_TABLE)
	for property_name in [
		"escape_material_multiplier",
		"kill_material_multiplier",
		"contain_material_multiplier",
		"heavy_error_loss_pct",
		"heavy_error_loss_cap",
	]:
		assert_true(_resource_has_property(payoffs, property_name), "%s should be exported data." % property_name)


func test_schema_validator_registers_settlement_payoff_resource() -> void:
	var source := FileAccess.get_file_as_string("res://tools/validate_schemas.gd")
	assert_string_contains(source, "\"SettlementPayoffResource\"")
	assert_string_contains(source, "heavy_error_loss_cap")


func test_abandoned_school_wires_settlement_runtime_nodes() -> void:
	if not ResourceLoader.exists(SCHOOL_SCENE):
		assert_true(false, "abandoned_school.tscn should exist.")
		return

	var school := _instantiate_scene(SCHOOL_SCENE)
	var calculator := school.get_node_or_null("SettlementCalculator")
	var screen := school.get_node_or_null("SettlementScreen")
	assert_not_null(calculator)
	assert_not_null(screen)
	if calculator != null:
		assert_eq(String(calculator.get("payoff_table_path")), SETTLEMENT_PAYOFF_TABLE)
	if screen != null:
		assert_ne(String(screen.get("placeholder_asset_note")).strip_edges(), "")


func _calculator_ready() -> bool:
	var ready := true
	for path in [SETTLEMENT_CALCULATOR_SCRIPT, SETTLEMENT_PAYOFF_RESOURCE_SCRIPT, SETTLEMENT_PAYOFF_TABLE]:
		if not ResourceLoader.exists(path):
			assert_true(false, "%s should exist." % path)
			ready = false
	return ready


func _screen_ready() -> bool:
	if not ResourceLoader.exists(SETTLEMENT_SCREEN_SCENE):
		assert_true(false, "%s should exist." % SETTLEMENT_SCREEN_SCENE)
		return false
	return true


func _make_calculator(auto_subscribe: bool) -> Node:
	var calculator: Node = load(SETTLEMENT_CALCULATOR_SCRIPT).new()
	calculator.auto_subscribe_event_bus = auto_subscribe
	calculator.payoff_table = load(SETTLEMENT_PAYOFF_TABLE)
	add_child_autofree(calculator)
	return calculator


func _settlement_input(objective_type: int, pickups: Array, hp: int, payload := {}, base_storage_total := 0) -> Dictionary:
	return {
		"objective_type": objective_type,
		"objective_payload": payload,
		"path_flag": _path_flag(objective_type),
		"hp_remaining": hp,
		"pickup_list": pickups,
		"triggered_rules": PackedStringArray(["rule_fixture"]),
		"base_storage_total": base_storage_total,
	}


func _pickup(category: String, amount: int) -> Dictionary:
	return {"category": category, "amount": amount}


func _path_flag(objective_type: int) -> String:
	match objective_type:
		OBJECTIVE_ESCAPE:
			return "escape"
		OBJECTIVE_KILL:
			return "kill"
		OBJECTIVE_CONTAIN:
			return "contain"
		OBJECTIVE_MISCONTAIN:
			return "miscontain"
		_:
			return ""


func _resource_total(payload: Dictionary) -> int:
	return int(payload.get("resource_summary", {}).get("total_awarded", 0))


func _origin_rank(payload: Dictionary) -> int:
	match String(payload.get("origin_output", {}).get("quality", "none")):
		"unstable":
			return 0
		"medium":
			return 1
		"high":
			return 2
		_:
			return -1


func _archive_entries(payload: Dictionary) -> int:
	return int(payload.get("archive_update", {}).get("entries_added", 0))


func _instantiate_scene(path: String) -> Node:
	var scene: PackedScene = load(path)
	var node := scene.instantiate()
	add_child_autofree(node)
	return node


func _label_text(root: Node, node_path: String) -> String:
	var label := root.get_node_or_null(node_path)
	assert_not_null(label, "%s should exist." % node_path)
	return "" if label == null else String(label.text)


func _resource_has_property(resource: Resource, property_name: String) -> bool:
	for property in resource.get_property_list():
		if String(property.get("name")) == property_name:
			return true
	return false
