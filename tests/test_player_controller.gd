extends GutTest

const PLAYER_SCENE_PATH := "res://scenes/player/player.tscn"
const MAIN_MENU_SCENE_PATH := "res://scenes/ui/main_menu.tscn"
const FLASHLIGHT_RESOURCE_PATH := "res://data/items/flashlight.tres"
const REQUIRED_ACTIONS := [
	"move_left",
	"move_right",
	"move_up",
	"move_down",
	"run",
	"crouch",
	"flashlight",
	"interact",
	"hide",
	"pause",
]


func test_required_input_actions_are_defined() -> void:
	for action in REQUIRED_ACTIONS:
		assert_true(InputMap.has_action(action), "Input Map should define %s." % action)


func test_flashlight_resource_exposes_runtime_parameters() -> void:
	assert_true(ResourceLoader.exists(FLASHLIGHT_RESOURCE_PATH), "flashlight.tres should exist.")
	if not ResourceLoader.exists(FLASHLIGHT_RESOURCE_PATH):
		return

	var flashlight: Resource = load(FLASHLIGHT_RESOURCE_PATH)
	assert_eq(flashlight.get("id"), "item_flashlight")
	assert_gt(float(flashlight.get("battery_capacity")), 0.0)
	assert_gt(float(flashlight.get("battery_drain_per_second")), 0.0)
	assert_gt(float(flashlight.get("low_battery_threshold")), 0.0)


func test_player_scene_has_required_runtime_nodes() -> void:
	assert_true(ResourceLoader.exists(PLAYER_SCENE_PATH), "player.tscn should exist.")
	if not ResourceLoader.exists(PLAYER_SCENE_PATH):
		return

	var player := _instantiate_player()
	assert_true(player is CharacterBody2D)
	assert_not_null(player.get_node_or_null("CollisionShape2D"))
	assert_not_null(player.get_node_or_null("Visual"))
	assert_not_null(player.get_node_or_null("Flashlight"))
	assert_not_null(player.get_node_or_null("FlashlightBeam"))
	assert_not_null(player.get_node_or_null("FollowCamera"))
	assert_not_null(player.get_node_or_null("FeedbackLabel"))
	assert_not_null(player.get_node_or_null("InteractionSensor"))
	assert_not_null(player.get_node_or_null("StateMachine"))
	assert_true(player.has_method("apply_movement_intent"))
	assert_true(player.has_method("set_flashlight_enabled"))
	assert_true(player.has_method("try_interact"))
	var camera := player.get_node("FollowCamera") as Camera2D
	assert_true(camera.enabled, "Player camera should be enabled so F6 playtest centers on the spawn.")


func test_main_menu_can_enter_playtest_scene() -> void:
	assert_true(ResourceLoader.exists(MAIN_MENU_SCENE_PATH), "main_menu.tscn should exist.")
	if not ResourceLoader.exists(MAIN_MENU_SCENE_PATH):
		return

	var scene: PackedScene = load(MAIN_MENU_SCENE_PATH)
	var menu := scene.instantiate()
	add_child_autofree(menu)

	assert_not_null(menu.get_node_or_null("StartPlaytestButton"))
	assert_true(ResourceLoader.exists(menu.get("playtest_scene_path")))


func test_player_movement_state_emits_noise_with_action_id() -> void:
	assert_true(ResourceLoader.exists(PLAYER_SCENE_PATH), "player.tscn should exist.")
	if not ResourceLoader.exists(PLAYER_SCENE_PATH):
		return

	var player := _instantiate_player()
	if not player.has_method("apply_movement_intent"):
		assert_true(false, "Player should expose apply_movement_intent for state-machine input.")
		return

	var last_noise := [{}]
	EventBus.noise_emitted.connect(
		func(level: int, position: Vector2, source_action_id: StringName) -> void:
			last_noise[0] = {
				"level": level,
				"position": position,
				"source_action_id": source_action_id,
			}
	)

	player.apply_movement_intent(Vector2.RIGHT, false, false, &"move_right")

	assert_eq(player.get_movement_state(), &"walk")
	assert_eq(last_noise[0].get("level", -1), 2)
	assert_eq(last_noise[0].get("source_action_id", &""), &"move_right")


func test_player_flashlight_consumes_battery_and_dims_when_low() -> void:
	assert_true(ResourceLoader.exists(PLAYER_SCENE_PATH), "player.tscn should exist.")
	if not ResourceLoader.exists(PLAYER_SCENE_PATH):
		return

	var player := _instantiate_player()
	if not player.has_method("set_flashlight_enabled"):
		assert_true(false, "Player should expose set_flashlight_enabled.")
		return

	var light := player.get_node("Flashlight") as PointLight2D
	var beam := player.get_node("FlashlightBeam") as CanvasItem
	player.set_flashlight_enabled(true)
	var start_battery: float = player.get_flashlight_battery()
	assert_true(beam.visible, "F should show a visible flashlight cone in the playtest scene.")
	player.tick_flashlight(1.0)
	assert_lt(player.get_flashlight_battery(), start_battery)

	player.tick_flashlight(999.0)
	assert_true(player.is_flashlight_low())
	assert_lt(light.energy, 1.0)
	assert_false(beam.visible)


func test_crouch_and_hide_actions_have_visible_feedback() -> void:
	var player := _instantiate_player()
	var body := player.get_node("PlaceholderBody") as CanvasItem
	var feedback := player.get_node("FeedbackLabel") as Label

	player.apply_movement_intent(Vector2.ZERO, false, true, &"crouch")
	assert_eq(player.get_movement_state(), &"crouch")
	assert_lt(body.scale.y, 1.0)

	var hide_result: Dictionary = player.try_toggle_hide()
	assert_eq(hide_result.get("result"), "none")
	assert_false(player.is_hidden())
	assert_eq(feedback.text, "需要靠近躲藏柜")


func test_playtest_interactable_returns_read_payload() -> void:
	var player := _instantiate_player()
	var interactable_script: Script = load("res://scripts/dungeon/playtest_interactable.gd")
	var interactable: Node = interactable_script.new()
	add_child_autofree(interactable)
	interactable.set("interaction_result", "read")
	interactable.set("note_id", &"note_test")
	interactable.set("note_text", "测试交互反馈")

	var payload: Dictionary = player.interact_with(interactable)
	assert_eq(payload.get("result"), "read")
	assert_true(player.has_read_note(&"note_test"))


func _instantiate_player() -> Node:
	var scene: PackedScene = load(PLAYER_SCENE_PATH)
	var player := scene.instantiate()
	add_child_autofree(player)
	return player
