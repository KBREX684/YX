extends Node
class_name PressureLevel

const AMBIENCE_BUS := "Ambience"
const SANITY_LOW_PASS_EFFECT_INDEX := 0

signal feedback_changed(snapshot: Dictionary)

@export var auto_subscribe_event_bus := true
@export_range(0.0, 100.0, 1.0) var max_sanity := 100.0
@export_range(0.0, 100.0, 1.0) var medium_sanity_threshold := 60.0
@export_range(0.0, 100.0, 1.0) var collapse_sanity_threshold := 20.0

var _current_level := 0.0
var _current_sanity := 100.0
var _heartbeat_intensity := 0.0
var _flashlight_flicker_hz := 0.0
var _ambience_volume_db := -18.0
var _screen_fx_intensity := 0.0
var _clue_reliability := 1.0
var _low_pass_enabled := false
var _sanity_shader_enabled := true


func _ready() -> void:
	add_to_group("pressure_level")
	_sanity_shader_enabled = bool(Config.get_value("accessibility", "sanity_shader_enabled", true))
	if auto_subscribe_event_bus and not EventBus.pressure_changed.is_connected(_on_pressure_changed):
		EventBus.pressure_changed.connect(_on_pressure_changed)
	_emit_feedback()


func _exit_tree() -> void:
	if EventBus.pressure_changed.is_connected(_on_pressure_changed):
		EventBus.pressure_changed.disconnect(_on_pressure_changed)


func apply_pressure_level(level: float) -> void:
	_current_level = clampf(level, 0.0, 1.0)
	_heartbeat_intensity = _current_level
	_flashlight_flicker_hz = lerpf(0.25, 9.0, _current_level)
	_ambience_volume_db = lerpf(-18.0, 3.0, _current_level)
	_apply_ambience_volume(_ambience_volume_db)
	EventBus.heartbeat_intensity_changed.emit(_heartbeat_intensity)
	_emit_feedback()


func apply_sanity_delta(delta: float) -> void:
	_current_sanity = clampf(_current_sanity + delta, 0.0, max_sanity)
	_clue_reliability = _reliability_for_sanity()
	_low_pass_enabled = _current_sanity < medium_sanity_threshold
	_screen_fx_intensity = _screen_fx_for_sanity()
	_apply_ambience_low_pass(_low_pass_enabled)
	EventBus.sanity_changed.emit(_current_sanity)
	_emit_feedback()


func get_current_level() -> float:
	return _current_level


func get_current_sanity() -> float:
	return _current_sanity


func get_clue_reliability() -> float:
	return _clue_reliability


func is_sanity_shader_enabled() -> bool:
	return _sanity_shader_enabled


func get_feedback_snapshot() -> Dictionary:
	return {
		"pressure_level": _current_level,
		"danger_band": _danger_band(),
		"heartbeat_intensity": _heartbeat_intensity,
		"flashlight_flicker_hz": _flashlight_flicker_hz,
		"ambience_volume_db": _ambience_volume_db,
		"light_anomaly_state": _light_anomaly_state(),
		"screen_fx_intensity": _screen_fx_intensity,
		"low_pass_enabled": _low_pass_enabled,
		"clue_reliability": _clue_reliability,
		"sanity": _current_sanity,
	}


func _on_pressure_changed(level: float) -> void:
	apply_pressure_level(level)


func _emit_feedback() -> void:
	feedback_changed.emit(get_feedback_snapshot())


func _danger_band() -> StringName:
	if _current_level >= 0.66:
		return &"near"
	if _current_level >= 0.25:
		return &"far"
	return &"quiet"


func _light_anomaly_state() -> StringName:
	if _current_level >= 0.8:
		return &"violent_flicker"
	if _current_level >= 0.35:
		return &"light_flicker"
	return &"normal"


func _reliability_for_sanity() -> float:
	if _current_sanity < collapse_sanity_threshold:
		return 0.4
	if _current_sanity < medium_sanity_threshold:
		return 0.75
	return 1.0


func _screen_fx_for_sanity() -> float:
	if not _sanity_shader_enabled:
		return 0.0
	if _current_sanity >= medium_sanity_threshold:
		return 0.0
	return clampf((medium_sanity_threshold - _current_sanity) / medium_sanity_threshold, 0.0, 1.0)


func _apply_ambience_low_pass(enabled: bool) -> void:
	var bus_index := AudioServer.get_bus_index(AMBIENCE_BUS)
	if bus_index == -1:
		return
	if AudioServer.get_bus_effect_count(bus_index) <= SANITY_LOW_PASS_EFFECT_INDEX:
		return
	AudioServer.set_bus_effect_enabled(bus_index, SANITY_LOW_PASS_EFFECT_INDEX, enabled)


func _apply_ambience_volume(volume_db: float) -> void:
	var bus_index := AudioServer.get_bus_index(AMBIENCE_BUS)
	if bus_index == -1:
		return
	AudioServer.set_bus_volume_db(bus_index, volume_db)
