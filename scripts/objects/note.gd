extends "res://scripts/objects/interactable.gd"

@export var note_id: StringName = &"clue_escape_notice_a"
@export var dialogic_timeline_id: StringName = &"dlg_p1_note_escape_notice"
@export_multiline var note_text := "后门锁链会在巡逻声远离后松动。"


func interact(player: Node) -> Dictionary:
	EventBus.clue_collected.emit(String(note_id))
	return _finish_interaction(player, "read", {
		"note_id": String(note_id),
		"dialogic_timeline_id": String(dialogic_timeline_id),
		"text": note_text,
	})
