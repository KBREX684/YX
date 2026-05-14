extends "res://scripts/objects/interactable.gd"
class_name ClueNote

@export var clue_data: Resource
@export var clue_id: StringName = &""
@export var dialogic_timeline_id: StringName = &""
@export_file("*.dtl") var dialogic_timeline_path := ""
@export_multiline var fallback_text := ""
@export_multiline var placeholder_asset_note := "占位: 线索物件（纸条/电台/档案），后续替换为正式厚涂分层 PNG。"


func get_clue_id() -> String:
	if clue_data != null and String(clue_data.get("clue_id")).strip_edges() != "":
		return String(clue_data.get("clue_id"))
	return String(clue_id)


func interact(player: Node) -> Dictionary:
	var id := get_clue_id()
	EventBus.clue_unlocked.emit(id)
	EventBus.clue_collected.emit(id)
	var started_dialogic := _try_start_dialogic()
	return _finish_interaction(player, "read", {
		"note_id": id,
		"clue_id": id,
		"dialogic_timeline_id": String(_timeline_id()),
		"dialogic_timeline_path": _timeline_path(),
		"text": _display_text(id),
		"dialogic_started": started_dialogic,
		"placeholder_asset_note": _placeholder_note(),
	})


func _timeline_id() -> StringName:
	if clue_data != null and StringName(clue_data.get("dialogic_timeline_id")) != &"":
		return StringName(clue_data.get("dialogic_timeline_id"))
	return dialogic_timeline_id


func _timeline_path() -> String:
	if clue_data != null and String(clue_data.get("dialogic_timeline_path")).strip_edges() != "":
		return String(clue_data.get("dialogic_timeline_path"))
	return dialogic_timeline_path


func _display_text(id: String) -> String:
	var tree := get_tree()
	if tree != null:
		var book := tree.get_first_node_in_group("clue_book")
		if book != null and book.has_method("get_display_text"):
			var display := String(book.call("get_display_text", id))
			if display.strip_edges() != "":
				return display
	if clue_data != null:
		return String(clue_data.get("archive_summary"))
	return fallback_text


func _placeholder_note() -> String:
	if clue_data != null and String(clue_data.get("placeholder_asset_note")).strip_edges() != "":
		return String(clue_data.get("placeholder_asset_note"))
	return placeholder_asset_note


func _try_start_dialogic() -> bool:
	var timeline := _timeline_path()
	if timeline.strip_edges() == "":
		return false
	var tree := get_tree()
	if tree == null:
		return false
	var dialogic := tree.root.get_node_or_null("Dialogic")
	if dialogic == null or not dialogic.has_method("start"):
		return false
	dialogic.call("start", timeline)
	return true
