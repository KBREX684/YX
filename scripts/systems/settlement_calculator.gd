extends Node
class_name SettlementCalculator

signal settlement_calculated(payload: Dictionary)

const OBJECTIVE_ESCAPE := 0
const OBJECTIVE_KILL := 1
const OBJECTIVE_CONTAIN := 2
const OBJECTIVE_MISCONTAIN := 3

const ROUTE_ESCAPE := "escape"
const ROUTE_KILL := "kill"
const ROUTE_CONTAIN := "contain"
const ROUTE_MISCONTAIN := "miscontain"

@export var payoff_table: Resource
@export var payoff_table_path := "res://data/settlement_payoffs.tres"
@export var auto_subscribe_event_bus := true

var _run_context: Dictionary = {}
var _last_settlement: Dictionary = {}


func _ready() -> void:
	add_to_group("settlement_calculator")
	_ensure_payoff_table()
	if auto_subscribe_event_bus:
		_subscribe_event_bus()


func _exit_tree() -> void:
	if EventBus.objective_completed.is_connected(_on_objective_completed):
		EventBus.objective_completed.disconnect(_on_objective_completed)


func set_run_context(context: Dictionary) -> void:
	_run_context = context.duplicate(true)


func get_last_settlement() -> Dictionary:
	return _last_settlement.duplicate(true)


func calculate(input: Dictionary) -> Dictionary:
	_ensure_payoff_table()
	var objective_type := int(input.get("objective_type", _objective_type_from_route(String(input.get("path_flag", "")))))
	var route := _route_from_objective(objective_type)
	if route == "":
		route = String(input.get("path_flag", ROUTE_ESCAPE))

	var payload := _objective_payload(input)
	var survived := int(input.get("hp_remaining", 1)) > 0
	var raw_summary := _summarize_pickups(input.get("pickup_list", []))
	var resource_summary := _apply_material_multiplier(raw_summary, _material_multiplier(route))
	if not survived:
		resource_summary = _apply_death_boundary(raw_summary, resource_summary)

	var base_delta := _base_resource_delta(route, resource_summary, input, payload)
	var result := {
		"settlement_type": route,
		"objective_type": objective_type,
		"survived": survived,
		"hp_remaining": int(input.get("hp_remaining", 0)),
		"triggered_rules": input.get("triggered_rules", PackedStringArray()),
		"resource_summary": resource_summary,
		"origin_output": _origin_output(route, payload),
		"archive_update": _archive_update(route),
		"base_resource_delta": base_delta,
		"base_invasion_trigger": _base_invasion_trigger(route, payload),
		"pollution_delta": _pollution_delta(route, survived),
	}
	_last_settlement = result.duplicate(true)
	return result


func calculate_and_emit(input: Dictionary) -> Dictionary:
	var result := calculate(input)
	settlement_calculated.emit(result)
	EventBus.settlement_ready.emit(result)
	return result


func _subscribe_event_bus() -> void:
	if not EventBus.objective_completed.is_connected(_on_objective_completed):
		EventBus.objective_completed.connect(_on_objective_completed)


func _on_objective_completed(objective_type: int, payload: Dictionary) -> void:
	var input := _run_context.duplicate(true)
	input["objective_type"] = objective_type
	input["objective_payload"] = payload.duplicate(true)
	if not input.has("path_flag"):
		input["path_flag"] = _route_from_objective(objective_type)
	calculate_and_emit(input)


func _ensure_payoff_table() -> void:
	if payoff_table == null and ResourceLoader.exists(payoff_table_path):
		payoff_table = load(payoff_table_path)


func _objective_payload(input: Dictionary) -> Dictionary:
	var value: Variant = input.get("objective_payload", {})
	return value.duplicate(true) if typeof(value) == TYPE_DICTIONARY else {}


func _route_from_objective(objective_type: int) -> String:
	match objective_type:
		OBJECTIVE_ESCAPE:
			return ROUTE_ESCAPE
		OBJECTIVE_KILL:
			return ROUTE_KILL
		OBJECTIVE_CONTAIN:
			return ROUTE_CONTAIN
		OBJECTIVE_MISCONTAIN:
			return ROUTE_MISCONTAIN
		_:
			return ""


func _objective_type_from_route(route: String) -> int:
	match route:
		ROUTE_ESCAPE:
			return OBJECTIVE_ESCAPE
		ROUTE_KILL:
			return OBJECTIVE_KILL
		ROUTE_CONTAIN:
			return OBJECTIVE_CONTAIN
		ROUTE_MISCONTAIN:
			return OBJECTIVE_MISCONTAIN
		_:
			return OBJECTIVE_ESCAPE


func _summarize_pickups(value: Variant) -> Dictionary:
	var summary := {
		"survival": 0,
		"puzzle": 0,
		"growth": 0,
		"intel": 0,
		"total_raw": 0,
	}
	if typeof(value) != TYPE_ARRAY:
		return summary

	for pickup in value:
		var category := "survival"
		var amount := 1
		if typeof(pickup) == TYPE_DICTIONARY:
			category = String(pickup.get("category", category))
			amount = int(pickup.get("amount", amount))
		else:
			category = String(pickup)
		if not summary.has(category):
			category = "survival"
		amount = maxi(amount, 0)
		summary[category] = int(summary[category]) + amount
		summary["total_raw"] = int(summary["total_raw"]) + amount
	return summary


func _apply_material_multiplier(raw_summary: Dictionary, multiplier: float) -> Dictionary:
	var result := raw_summary.duplicate(true)
	var total_awarded := 0
	for category in ["survival", "puzzle", "growth", "intel"]:
		var value := int(round(float(raw_summary.get(category, 0)) * multiplier))
		result[category] = maxi(value, 0)
		total_awarded += int(result[category])
	result["total_awarded"] = total_awarded
	result["lost"] = maxi(int(raw_summary.get("total_raw", 0)) - total_awarded, 0)
	return result


func _apply_death_boundary(raw_summary: Dictionary, _resource_summary: Dictionary) -> Dictionary:
	var ratio := _payoff_float("death_resource_return_ratio", 0.0)
	return _apply_material_multiplier(raw_summary, ratio)


func _material_multiplier(route: String) -> float:
	return _payoff_float("%s_material_multiplier" % route, 1.0)


func _origin_output(route: String, payload: Dictionary) -> Dictionary:
	match route:
		ROUTE_ESCAPE:
			return {
				"granted": false,
				"quality": "none",
				"stability": "none",
				"route_affinity": "none",
				"quality_rank": -1,
			}
		ROUTE_KILL:
			return _origin_payload(payload, "kill", "combat", 1)
		ROUTE_CONTAIN:
			return _origin_payload(payload, "contain", "containment", 2)
		ROUTE_MISCONTAIN:
			return _origin_payload(payload, "miscontain", "unstable", 0)
		_:
			return {}


func _origin_payload(payload: Dictionary, route: String, affinity: String, rank: int) -> Dictionary:
	var quality := String(payload.get("origin_quality", _payoff_string("%s_origin_quality" % route, "none")))
	var stability := String(payload.get("origin_stability", _payoff_string("%s_origin_stability" % route, "none")))
	return {
		"granted": quality != "none",
		"quality": quality,
		"stability": stability,
		"route_affinity": affinity,
		"quality_rank": rank,
	}


func _archive_update(route: String) -> Dictionary:
	return {
		"entries_added": _payoff_int("%s_archive_entries" % route, 0),
		"completion_percent": _payoff_int("%s_archive_completion_percent" % route, 0),
		"completion_label": route,
	}


func _base_resource_delta(route: String, resource_summary: Dictionary, input: Dictionary, payload: Dictionary) -> Dictionary:
	var loss := _miscontainment_loss(route, input, payload)
	if route == ROUTE_MISCONTAIN:
		return {
			"placeholder_materials": -loss,
			"gained": 0,
			"lost": loss,
			"placeholder_asset_note": "P5 will replace this placeholder field with formal base storage resources.",
		}
	return {
		"placeholder_materials": int(resource_summary.get("total_awarded", 0)),
		"gained": int(resource_summary.get("total_awarded", 0)),
		"lost": 0,
		"placeholder_asset_note": "P5 will replace this placeholder field with formal base storage resources.",
	}


func _miscontainment_loss(route: String, input: Dictionary, payload: Dictionary) -> int:
	if route != ROUTE_MISCONTAIN:
		return 0
	var failure_level := String(payload.get("failure_level", "medium"))
	var storage_total := int(input.get("base_storage_total", 0))
	var pct := _payoff_float("%s_error_loss_pct" % failure_level, _payoff_float("medium_error_loss_pct", 0.1))
	var cap := _payoff_int("%s_error_loss_cap" % failure_level, _payoff_int("medium_error_loss_cap", 8))
	return mini(int(round(float(storage_total) * pct)), cap)


func _base_invasion_trigger(route: String, payload: Dictionary) -> Dictionary:
	if route != ROUTE_MISCONTAIN:
		return {"enabled": false, "chance": 0.0, "failure_level": ""}
	var failure_level := String(payload.get("failure_level", "medium"))
	return {
		"enabled": true,
		"chance": _payoff_float("%s_error_invasion_chance" % failure_level, 0.3),
		"failure_level": failure_level,
	}


func _pollution_delta(route: String, survived: bool) -> Dictionary:
	return {
		"player": 0.05 if route == ROUTE_MISCONTAIN else 0.0,
		"base": 0.1 if route == ROUTE_MISCONTAIN else 0.0,
		"death_penalty_pending": not survived,
	}


func _payoff_string(property_name: String, fallback: String) -> String:
	if payoff_table != null and _resource_has_property(payoff_table, property_name):
		return String(payoff_table.get(property_name))
	return fallback


func _payoff_int(property_name: String, fallback: int) -> int:
	if payoff_table != null and _resource_has_property(payoff_table, property_name):
		return int(payoff_table.get(property_name))
	return fallback


func _payoff_float(property_name: String, fallback: float) -> float:
	if payoff_table != null and _resource_has_property(payoff_table, property_name):
		return float(payoff_table.get(property_name))
	return fallback


func _resource_has_property(resource: Resource, property_name: String) -> bool:
	for property in resource.get_property_list():
		if String(property.get("name")) == property_name:
			return true
	return false
