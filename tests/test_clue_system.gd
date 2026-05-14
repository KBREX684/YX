extends GutTest

const PLAYER_SCENE_PATH := "res://scenes/player/player.tscn"
const SCHOOL_SCENE_PATH := "res://scenes/dungeon/abandoned_school.tscn"
const CLUE_RESOURCE_SCRIPT := "res://scripts/systems/resources/clue_resource.gd"
const CLUE_BOOK_SCRIPT := "res://scripts/systems/clue_book.gd"
const CLUE_NOTE_SCENE_PATH := "res://scenes/objects/clue_note.tscn"
const VERIFICATION_RULE_PATH := "res://data/rules/da_zhi/rule_da_zhi_roster_reaction_verification.tres"

const EXPECTED_CLUE_FILES := [
	"res://data/clues/escape_exit_lock.tres",
	"res://data/clues/escape_power_room_tag.tres",
	"res://data/clues/escape_route_map.tres",
	"res://data/clues/kill_corridor_echo.tres",
	"res://data/clues/kill_broadcast_dependency.tres",
	"res://data/clues/kill_broadcast_power_cut.tres",
	"res://data/clues/contain_full_roster.tres",
	"res://data/clues/contain_missing_name.tres",
	"res://data/clues/contain_ritual_cord_left.tres",
	"res://data/clues/contain_ritual_cord_right.tres",
	"res://data/clues/contain_silence_taboo.tres",
]


func before_each() -> void:
	if GameState.has_method("clear_known_clues"):
		GameState.clear_known_clues()


func test_clue_system_files_and_event_contract_exist() -> void:
	assert_true(ResourceLoader.exists(CLUE_RESOURCE_SCRIPT), "ClueResource script should exist.")
	assert_true(ResourceLoader.exists(CLUE_BOOK_SCRIPT), "ClueBook script should exist.")
	assert_true(ResourceLoader.exists(CLUE_NOTE_SCENE_PATH), "clue_note.tscn should exist.")
	assert_true(EventBus.has_signal("clue_unlocked"), "EventBus should expose clue_unlocked(clue_id).")
	assert_true(GameState.has_method("record_clue"), "GameState should record known clues.")
	assert_true(GameState.has_method("knows_clue"), "GameState should query known clues.")
	assert_true(GameState.has_method("clear_known_clues"), "GameState should clear run clue state.")


func test_clue_data_has_required_route_counts_and_dialogic_timelines() -> void:
	var route_counts := {"escape": 0, "kill": 0, "contain": 0}
	for path in EXPECTED_CLUE_FILES:
		assert_true(ResourceLoader.exists(path), "%s should exist." % path)
		if not ResourceLoader.exists(path):
			continue
		var clue: Resource = load(path)
		var clue_id := String(clue.get("clue_id"))
		var route := String(clue.get("route"))
		var timeline_path := String(clue.get("dialogic_timeline_path"))

		assert_string_starts_with(clue_id, "clue_")
		assert_true(route_counts.has(route), "%s route should be tracked." % route)
		if route_counts.has(route):
			route_counts[route] += 1
		assert_false(timeline_path.strip_edges().is_empty())
		assert_true(FileAccess.file_exists(timeline_path), "%s timeline should exist." % clue_id)
		assert_false(String(clue.get("archive_summary")).strip_edges().is_empty())
		assert_false(String(clue.get("placeholder_asset_note")).strip_edges().is_empty())

	assert_eq(route_counts["escape"], 3)
	assert_eq(route_counts["kill"], 3)
	assert_eq(route_counts["contain"], 5)


func test_clue_note_unlocks_clue_and_payload_links_dialogic() -> void:
	if not _clue_note_ready():
		return
	if not ResourceLoader.exists("res://data/clues/kill_corridor_echo.tres"):
		assert_true(false, "fixture clue should exist.")
		return

	var player := _instantiate_scene(PLAYER_SCENE_PATH)
	var clue_note := _instantiate_scene(CLUE_NOTE_SCENE_PATH)
	clue_note.clue_data = load("res://data/clues/kill_corridor_echo.tres")

	var unlocked := [""]
	EventBus.connect("clue_unlocked", func(clue_id: String) -> void: unlocked[0] = clue_id)
	var payload: Dictionary = player.interact_with(clue_note)

	assert_eq(payload.get("result"), "read")
	assert_eq(payload.get("clue_id"), "clue_corridor_echo")
	assert_eq(payload.get("note_id"), "clue_corridor_echo")
	assert_string_starts_with(String(payload.get("dialogic_timeline_path")), "res://dialogic/timelines/")
	assert_eq(unlocked[0], "clue_corridor_echo")
	assert_true(player.has_read_note(&"clue_corridor_echo"))


func test_clue_book_records_unique_clues_in_game_state() -> void:
	if not _clue_book_ready():
		return

	var book := _make_clue_book(false)
	assert_true(book.register_clue("clue_corridor_echo"))
	assert_false(book.register_clue("clue_corridor_echo"))

	assert_true(book.has_clue("clue_corridor_echo"))
	assert_eq(book.get_known_clue_ids().size(), 1)
	assert_true(GameState.knows_clue("clue_corridor_echo"))
	assert_eq(book.get_route_completion("kill").get("known"), 1)


func test_event_bus_clue_unlocked_is_consumed_by_clue_book() -> void:
	if not _clue_book_ready():
		return

	var book := _make_clue_book(true)
	EventBus.emit_signal("clue_unlocked", "clue_broadcast_dependency")

	assert_true(book.has_clue("clue_broadcast_dependency"))
	assert_true(GameState.knows_clue("clue_broadcast_dependency"))


func test_low_sanity_reliability_interferes_with_clue_display() -> void:
	if not _clue_book_ready():
		return

	var book := _make_clue_book(false)
	book.register_clue("clue_broadcast_dependency")

	var normal := String(book.get_display_text("clue_broadcast_dependency", 1.0))
	var distorted := String(book.get_display_text("clue_broadcast_dependency", 0.4))

	assert_ne(normal, distorted)
	assert_string_contains(normal, "broadcast")
	assert_string_contains(distorted, "[干扰]")


func test_containment_behavior_verification_rule_updates_clue_book() -> void:
	if not _clue_book_ready():
		return
	assert_true(ResourceLoader.exists(VERIFICATION_RULE_PATH), "verification RuleResource should exist.")
	if not ResourceLoader.exists(VERIFICATION_RULE_PATH):
		return

	var book := _make_clue_book(true)
	book.register_clue("clue_full_roster")

	var engine: Node = load("res://scripts/systems/rule_engine.gd").new()
	engine.auto_subscribe_event_bus = false
	engine.rules.assign([load(VERIFICATION_RULE_PATH)])
	add_child_autofree(engine)

	var triggered: Array = engine.evaluate({
		"clue_id": "clue_full_roster",
		"known_clues": PackedStringArray(["clue_full_roster"]),
		"verification_action": "display_roster",
	})

	assert_eq(triggered.size(), 1)
	assert_true(book.is_clue_verified("clue_full_roster"))
	assert_false(book.get_verification_label("clue_full_roster").strip_edges().is_empty())


func test_abandoned_school_wires_clue_book_and_clue_notes() -> void:
	if not ResourceLoader.exists(SCHOOL_SCENE_PATH):
		assert_true(false, "abandoned_school.tscn should exist.")
		return

	var school := _instantiate_scene(SCHOOL_SCENE_PATH)
	var clue_book := school.get_node_or_null("ClueBook")
	var interactables := school.get_node_or_null("Interactables")
	assert_not_null(clue_book)
	assert_not_null(interactables)
	if clue_book == null or interactables == null:
		return

	assert_eq(clue_book.clue_resources.size(), EXPECTED_CLUE_FILES.size())
	assert_gte(_count_clue_notes(interactables), EXPECTED_CLUE_FILES.size())


func _clue_note_ready() -> bool:
	var ready := true
	if not ResourceLoader.exists(CLUE_NOTE_SCENE_PATH):
		assert_true(false, "clue_note.tscn should exist.")
		ready = false
	if not ResourceLoader.exists(PLAYER_SCENE_PATH):
		assert_true(false, "player.tscn should exist.")
		ready = false
	if not EventBus.has_signal("clue_unlocked"):
		assert_true(false, "EventBus.clue_unlocked should exist.")
		ready = false
	return ready


func _clue_book_ready() -> bool:
	var ready := true
	if not ResourceLoader.exists(CLUE_BOOK_SCRIPT):
		assert_true(false, "clue_book.gd should exist.")
		ready = false
	if not GameState.has_method("record_clue"):
		assert_true(false, "GameState.record_clue should exist.")
		ready = false
	if not EventBus.has_signal("clue_unlocked"):
		assert_true(false, "EventBus.clue_unlocked should exist.")
		ready = false
	return ready


func _make_clue_book(auto_subscribe: bool) -> Node:
	var book: Node = load(CLUE_BOOK_SCRIPT).new()
	book.auto_subscribe_event_bus = auto_subscribe
	book.clue_resources.assign(_load_expected_clues())
	add_child_autofree(book)
	return book


func _load_expected_clues() -> Array:
	var clues := []
	for path in EXPECTED_CLUE_FILES:
		if ResourceLoader.exists(path):
			clues.append(load(path))
	return clues


func _count_clue_notes(root: Node) -> int:
	var count := 0
	for child in root.get_children():
		if child.has_method("get_clue_id"):
			count += 1
	return count


func _instantiate_scene(path: String) -> Node:
	var scene: PackedScene = load(path)
	var node := scene.instantiate()
	add_child_autofree(node)
	return node
