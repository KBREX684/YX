extends Area2D
class_name PlaytestInteractable

@export var interactable_id: StringName = &"playtest_interactable"
@export var interaction_result := "read"
@export var note_id: StringName = &"playtest_note"
@export_multiline var note_text := "占位交互反馈：后续替换为正式线索、门牌或物件检查演出。"

signal interacted(interactor: Node, payload: Dictionary)


func interact(player: Node) -> Dictionary:
	var payload := {
		"id": String(interactable_id),
		"result": interaction_result,
		"note_id": String(note_id),
		"text": note_text,
	}
	interacted.emit(player, payload)
	return payload
