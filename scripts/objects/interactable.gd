extends Area2D
class_name Interactable

signal interacted(interactor: Node, payload: Dictionary)

@export var interactable_id: StringName = &"interactable"
@export var prompt_text := "Interact"


func interact(player: Node) -> Dictionary:
	return _finish_interaction(player, "noop")


func _finish_interaction(player: Node, result: String, extra: Dictionary = {}) -> Dictionary:
	var payload := {
		"id": String(interactable_id),
		"result": result,
	}
	payload.merge(extra, true)
	interacted.emit(player, payload)
	return payload
