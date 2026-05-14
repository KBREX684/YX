extends GutTest

const MICRO_SCENE_PATH := "res://scenes/dungeon/micro_school_blockout.tscn"
const SCHOOL_SCENE_PATH := "res://scenes/dungeon/abandoned_school.tscn"
const ROOM_POOL_SCRIPT := "res://scripts/systems/room_pool.gd"
const LEVEL_RESOURCE_PATH := "res://data/levels/abandoned_school.tres"
const LEVEL_MANIFEST_PATH := "res://data/manifest/level_manifest.tres"


func test_room_pool_draw_is_deterministic_and_unique() -> void:
	assert_true(ResourceLoader.exists(ROOM_POOL_SCRIPT), "room_pool.gd should exist.")
	if not ResourceLoader.exists(ROOM_POOL_SCRIPT):
		return

	var pool: Object = load(ROOM_POOL_SCRIPT).new()
	var candidates := PackedStringArray([
		"room_classroom_a",
		"room_storage_a",
		"room_restroom_a",
		"room_office_a",
	])
	var first: PackedStringArray = pool.draw_room_ids(candidates, 4, 6, 1729)
	var second: PackedStringArray = pool.draw_room_ids(candidates, 4, 6, 1729)

	assert_eq(first, second)
	assert_eq(first.size(), 4)
	assert_eq(_unique_count(first), first.size())


func test_micro_school_blockout_has_required_micro_slice_nodes() -> void:
	assert_true(ResourceLoader.exists(MICRO_SCENE_PATH), "micro_school_blockout.tscn should exist.")
	if not ResourceLoader.exists(MICRO_SCENE_PATH):
		return

	var level := _instantiate_scene(MICRO_SCENE_PATH)
	for path in [
		"World/MainCorridor",
		"World/RoomClassroomA",
		"World/RoomStorageA",
		"World/HidingSpot",
		"World/InteractionStub",
		"World/MapChangeEvent",
		"World/EscapePath",
		"World/WorldBounds",
		"NavigationRegion2D",
		"PlayerSpawn",
		"Player",
	]:
		assert_not_null(level.get_node_or_null(path), "Expected node %s." % path)

	for path in ["World/HidingSpot", "World/InteractionStub"]:
		var node := level.get_node(path)
		assert_true(node.has_method("interact"), "%s should be interactable during playtest." % path)
		assert_not_null(node.get_node_or_null("PlaceholderVisual"), "%s should have visible placeholder geometry." % path)

	assert_eq(level.get_node("World/WorldBounds").get_child_count(), 4)


func test_micro_map_change_event_is_triggerable_and_keeps_escape_path() -> void:
	assert_true(ResourceLoader.exists(MICRO_SCENE_PATH), "micro_school_blockout.tscn should exist.")
	if not ResourceLoader.exists(MICRO_SCENE_PATH):
		return

	var level := _instantiate_scene(MICRO_SCENE_PATH)
	var event := level.get_node("World/MapChangeEvent")
	assert_true(event.has_method("trigger"))
	assert_true(event.trigger())
	assert_true(level.has_node("World/EscapePath"))


func test_abandoned_school_has_required_sections_and_candidate_rooms() -> void:
	assert_true(ResourceLoader.exists(SCHOOL_SCENE_PATH), "abandoned_school.tscn should exist.")
	if not ResourceLoader.exists(SCHOOL_SCENE_PATH):
		return

	var level := _instantiate_scene(SCHOOL_SCENE_PATH)
	for path in [
		"Sections/Entrance",
		"Sections/MainCorridor",
		"Sections/RitualRoom",
		"Sections/ExitArea",
		"CandidateRooms",
		"NavigationRegion2D",
	]:
		assert_not_null(level.get_node_or_null(path), "Expected node %s." % path)

	var room_count := level.get_node("CandidateRooms").get_child_count()
	assert_gte(room_count, 4)
	assert_lte(room_count, 6)


func test_level_resource_and_manifest_use_stable_ids() -> void:
	assert_true(ResourceLoader.exists(LEVEL_RESOURCE_PATH), "abandoned_school.tres should exist.")
	assert_true(ResourceLoader.exists(LEVEL_MANIFEST_PATH), "level_manifest.tres should exist.")
	if not ResourceLoader.exists(LEVEL_RESOURCE_PATH) or not ResourceLoader.exists(LEVEL_MANIFEST_PATH):
		return

	var level: Resource = load(LEVEL_RESOURCE_PATH)
	var manifest: Resource = load(LEVEL_MANIFEST_PATH)
	assert_eq(level.get("id"), "level_abandoned_school")
	assert_has(level.get("room_ids"), "room_classroom_a")
	assert_has(level.get("map_event_ids"), "event_corridor_stretch")

	var entries: Dictionary = manifest.get("entries")
	assert_true(entries.has("level_abandoned_school"))
	assert_true(entries.has("room_classroom_a"))
	assert_true(entries.has("event_corridor_stretch"))


func _instantiate_scene(path: String) -> Node:
	var scene: PackedScene = load(path)
	var node := scene.instantiate()
	add_child_autofree(node)
	return node


func _unique_count(values: PackedStringArray) -> int:
	var seen := {}
	for value in values:
		seen[value] = true
	return seen.size()
