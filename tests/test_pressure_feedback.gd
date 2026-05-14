extends GutTest

const PRESSURE_SCRIPT := "res://scripts/systems/pressure_level.gd"
const PRESSURE_HUD_SCENE := "res://scenes/ui/hud/pressure_hud.tscn"
const HEARTBEAT_SCENE := "res://scenes/audio/heartbeat_player.tscn"
const AUDIO_BUS_LAYOUT := "res://data/audio/heartbeat_busses.tres"
const SANITY_SHADER := "res://scripts/shaders/sanity_distort.gdshader"
const FIRST_ENTRY_TRIGGER_SCRIPT := "res://scripts/dungeon/first_entry_manifest_trigger.gd"
const ABANDONED_SCHOOL_SCENE := "res://scenes/dungeon/abandoned_school.tscn"
const DA_ZHI_SCENE_PATH := "res://scenes/monster/da_zhi.tscn"
const RULE_ENGINE_SCRIPT := "res://scripts/systems/rule_engine.gd"
const RUN_RULE_PATH := "res://data/rules/da_zhi/rule_da_zhi_corridor_run.tres"
const MANIFEST_RULE_PATH := "res://data/rules/da_zhi/rule_da_zhi_first_manifestation.tres"


func before_each() -> void:
	Config.set_value("accessibility", "sanity_shader_enabled", true)


func test_required_pressure_feedback_files_exist() -> void:
	for path in [PRESSURE_SCRIPT, PRESSURE_HUD_SCENE, HEARTBEAT_SCENE, AUDIO_BUS_LAYOUT, SANITY_SHADER, FIRST_ENTRY_TRIGGER_SCRIPT]:
		assert_true(ResourceLoader.exists(path), "%s should exist." % path)


func test_event_bus_and_audio_buses_are_configured() -> void:
	assert_true(EventBus.has_signal("pressure_changed"))
	assert_ne(AudioServer.get_bus_index("Heartbeat"), -1)
	assert_ne(AudioServer.get_bus_index("Flashlight"), -1)
	var ambience_bus := AudioServer.get_bus_index("Ambience")
	assert_ne(ambience_bus, -1)
	assert_gt(AudioServer.get_bus_effect_count(ambience_bus), 0)


func test_pressure_level_maps_far_and_near_feedback() -> void:
	if not ResourceLoader.exists(PRESSURE_SCRIPT):
		assert_true(false, "pressure_level.gd should exist.")
		return

	var pressure := _make_pressure()
	pressure.apply_pressure_level(0.25)
	var far: Dictionary = pressure.get_feedback_snapshot()
	pressure.apply_pressure_level(0.85)
	var near: Dictionary = pressure.get_feedback_snapshot()

	assert_lt(float(far["heartbeat_intensity"]), float(near["heartbeat_intensity"]))
	assert_lt(float(far["flashlight_flicker_hz"]), float(near["flashlight_flicker_hz"]))
	assert_lt(float(far["ambience_volume_db"]), float(near["ambience_volume_db"]))
	assert_eq(near["danger_band"], &"near")


func test_pressure_level_consumes_event_bus_and_updates_sanity() -> void:
	if not ResourceLoader.exists(PRESSURE_SCRIPT):
		return

	var pressure := _make_pressure()
	EventBus.pressure_changed.emit(0.7)
	assert_almost_eq(pressure.get_current_level(), 0.7, 0.01)

	pressure.apply_sanity_delta(-45.0)
	assert_lt(pressure.get_clue_reliability(), 1.0)
	assert_true(AudioServer.is_bus_effect_enabled(AudioServer.get_bus_index("Ambience"), 0))
	assert_signal_emitted(EventBus, "sanity_changed")


func test_sanity_shader_can_be_disabled_by_config() -> void:
	if not ResourceLoader.exists(PRESSURE_SCRIPT):
		return

	Config.set_value("accessibility", "sanity_shader_enabled", false)
	var pressure := _make_pressure()
	pressure.apply_sanity_delta(-80.0)
	var snapshot: Dictionary = pressure.get_feedback_snapshot()

	assert_false(pressure.is_sanity_shader_enabled())
	assert_eq(float(snapshot["screen_fx_intensity"]), 0.0)


func test_pressure_hud_and_heartbeat_scene_react_to_level() -> void:
	if not ResourceLoader.exists(PRESSURE_HUD_SCENE) or not ResourceLoader.exists(HEARTBEAT_SCENE):
		assert_true(false, "HUD and heartbeat scenes should exist.")
		return

	var hud := _instantiate_scene(PRESSURE_HUD_SCENE)
	assert_true(hud is CanvasLayer)
	assert_not_null(hud.get_node_or_null("Root/HeartbeatVignette"))
	assert_not_null(hud.get_node_or_null("Root/FlashlightFlicker"))

	var heartbeat := _instantiate_scene(HEARTBEAT_SCENE)
	assert_not_null(heartbeat.get_node_or_null("HeartbeatPlayer2D"))
	heartbeat.apply_pressure_level(0.85)
	var player := heartbeat.get_node("HeartbeatPlayer2D") as AudioStreamPlayer2D
	assert_eq(player.bus, "Heartbeat")
	assert_gt(player.pitch_scale, 1.0)
	assert_gt(player.volume_db, -24.0)


func test_sanity_shader_declares_expected_uniforms() -> void:
	assert_true(ResourceLoader.exists(SANITY_SHADER), "sanity_distort.gdshader should exist.")
	if not ResourceLoader.exists(SANITY_SHADER):
		return

	var source := FileAccess.get_file_as_string(SANITY_SHADER)
	assert_string_contains(source, "shader_type canvas_item")
	assert_string_contains(source, "sanity_intensity")
	assert_string_contains(source, "vertex")


func test_da_zhi_phase_and_manifestation_emit_pressure() -> void:
	if not _runtime_files_exist():
		return

	var _da_zhi := _instantiate_scene(DA_ZHI_SCENE_PATH)
	var engine := _make_engine([load(RUN_RULE_PATH), load(MANIFEST_RULE_PATH)])
	var last_pressure := [-1.0]
	EventBus.pressure_changed.connect(func(level: float) -> void: last_pressure[0] = level)

	engine.evaluate({
		"source_action_id": &"run",
		"zone_id": "main_corridor",
		"noise_level": 3,
	})
	assert_gte(last_pressure[0], 0.6)

	engine.evaluate({
		"entered_main_corridor": true,
		"first_visit": true,
	})
	assert_gte(last_pressure[0], 0.6)


func test_abandoned_school_wires_first_entry_pressure_feedback() -> void:
	if not ResourceLoader.exists(ABANDONED_SCHOOL_SCENE):
		assert_true(false, "abandoned_school.tscn should exist.")
		return

	var dungeon := _instantiate_scene(ABANDONED_SCHOOL_SCENE)
	var pressure: Node = dungeon.get_node_or_null("PressureLevel")
	var da_zhi: Node = dungeon.get_node_or_null("Monsters/DaZhi")
	var trigger: Node = dungeon.get_node_or_null("FirstEntryManifestTrigger")
	var heartbeat: Node = dungeon.get_node_or_null("Audio/HeartbeatPlayer")

	assert_not_null(pressure)
	assert_not_null(da_zhi)
	assert_not_null(trigger)
	assert_not_null(dungeon.get_node_or_null("PressureHud"))
	assert_not_null(heartbeat)
	assert_true(trigger.trigger_once())
	assert_true(da_zhi.is_manifested())
	assert_gte(pressure.get_current_level(), 0.6)
	assert_gt(heartbeat.get_player().pitch_scale, 0.75)


func _make_pressure() -> Node:
	var pressure: Node = load(PRESSURE_SCRIPT).new()
	watch_signals(EventBus)
	add_child_autofree(pressure)
	return pressure


func _instantiate_scene(path: String) -> Node:
	var scene: PackedScene = load(path)
	var node := scene.instantiate()
	add_child_autofree(node)
	return node


func _make_engine(rules: Array) -> Node:
	var engine: Node = load(RULE_ENGINE_SCRIPT).new()
	engine.auto_subscribe_event_bus = false
	engine.rules.assign(rules)
	add_child_autofree(engine)
	return engine


func _runtime_files_exist() -> bool:
	for path in [DA_ZHI_SCENE_PATH, RULE_ENGINE_SCRIPT, RUN_RULE_PATH, MANIFEST_RULE_PATH]:
		if not ResourceLoader.exists(path):
			assert_true(false, "%s should exist." % path)
			return false
	return true
