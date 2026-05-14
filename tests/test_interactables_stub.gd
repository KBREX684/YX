extends GutTest

const PLAYER_SCENE_PATH := "res://scenes/player/player.tscn"
const DOOR_SCENE_PATH := "res://scenes/objects/door.tscn"
const PICKUP_SCENE_PATH := "res://scenes/objects/pickup.tscn"
const NOTE_SCENE_PATH := "res://scenes/objects/note.tscn"
const HIDING_SPOT_SCENE_PATH := "res://scenes/objects/hiding_spot.tscn"
const SCHOOL_SCENE_PATH := "res://scenes/dungeon/abandoned_school.tscn"


func test_interactable_scenes_exist_and_share_interface() -> void:
	for path in [DOOR_SCENE_PATH, PICKUP_SCENE_PATH, NOTE_SCENE_PATH, HIDING_SPOT_SCENE_PATH]:
		assert_true(ResourceLoader.exists(path), "%s should exist." % path)
		if ResourceLoader.exists(path):
			var node := _instantiate_scene(path)
			assert_true(node is Area2D)
			assert_true(node.has_method("interact"))


func test_door_opens_and_respects_locked_flag() -> void:
	assert_true(ResourceLoader.exists(DOOR_SCENE_PATH), "door.tscn should exist.")
	if not ResourceLoader.exists(DOOR_SCENE_PATH):
		return

	var player := _instantiate_scene(PLAYER_SCENE_PATH)
	var door := _instantiate_scene(DOOR_SCENE_PATH)
	assert_false(door.is_open)
	assert_eq(player.interact_with(door).get("result"), "opened")
	assert_true(door.is_open)

	door.is_locked = true
	assert_eq(player.interact_with(door).get("result"), "locked")
	assert_true(door.is_open)


func test_pickup_writes_temporary_inventory() -> void:
	assert_true(ResourceLoader.exists(PICKUP_SCENE_PATH), "pickup.tscn should exist.")
	if not ResourceLoader.exists(PICKUP_SCENE_PATH):
		return

	var player := _instantiate_scene(PLAYER_SCENE_PATH)
	var pickup := _instantiate_scene(PICKUP_SCENE_PATH)
	pickup.item_id = &"item_battery_aa"
	pickup.amount = 2

	var result: Dictionary = player.interact_with(pickup)
	assert_eq(result.get("result"), "picked_up")
	assert_eq(player.get_temp_item_count(&"item_battery_aa"), 2)
	assert_false(pickup.monitoring)


func test_note_records_read_state_and_clue_event() -> void:
	assert_true(ResourceLoader.exists(NOTE_SCENE_PATH), "note.tscn should exist.")
	if not ResourceLoader.exists(NOTE_SCENE_PATH):
		return

	var player := _instantiate_scene(PLAYER_SCENE_PATH)
	var note := _instantiate_scene(NOTE_SCENE_PATH)
	note.note_id = &"clue_escape_notice_a"

	var last_clue := [""]
	EventBus.clue_collected.connect(func(clue_id: String) -> void: last_clue[0] = clue_id)
	var result: Dictionary = player.interact_with(note)

	assert_eq(result.get("result"), "read")
	assert_true(player.has_read_note(&"clue_escape_notice_a"))
	assert_eq(last_clue[0], "clue_escape_notice_a")
	assert_ne(note.dialogic_timeline_id, &"")


func test_hiding_spot_sets_player_hidden_state() -> void:
	assert_true(ResourceLoader.exists(HIDING_SPOT_SCENE_PATH), "hiding_spot.tscn should exist.")
	if not ResourceLoader.exists(HIDING_SPOT_SCENE_PATH):
		return

	var player := _instantiate_scene(PLAYER_SCENE_PATH)
	var hiding_spot := _instantiate_scene(HIDING_SPOT_SCENE_PATH)
	var result: Dictionary = player.interact_with(hiding_spot)

	assert_eq(result.get("result"), "hidden")
	assert_true(player.is_hidden())
	assert_eq(player.get_movement_state(), &"hide")


func test_abandoned_school_contains_interactable_instances() -> void:
	assert_true(ResourceLoader.exists(SCHOOL_SCENE_PATH), "abandoned_school.tscn should exist.")
	if not ResourceLoader.exists(SCHOOL_SCENE_PATH):
		return

	var school := _instantiate_scene(SCHOOL_SCENE_PATH)
	var container := school.get_node_or_null("Interactables")
	assert_not_null(container)
	if container == null:
		return
	assert_gte(container.get_child_count(), 5)
	assert_not_null(container.get_node_or_null("EntranceDoor"))
	assert_not_null(container.get_node_or_null("ExitDoor"))
	assert_not_null(container.get_node_or_null("BatteryPickup"))
	assert_not_null(container.get_node_or_null("RuleNote"))
	assert_not_null(container.get_node_or_null("LockerHidingSpot"))


func _instantiate_scene(path: String) -> Node:
	var scene: PackedScene = load(path)
	var node := scene.instantiate()
	add_child_autofree(node)
	return node
