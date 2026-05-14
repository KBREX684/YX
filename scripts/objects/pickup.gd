extends "res://scripts/objects/interactable.gd"

@export var item_id: StringName = &"item_battery_aa"
@export var amount := 1

var picked_up := false


func interact(player: Node) -> Dictionary:
	if picked_up:
		return _finish_interaction(player, "empty", {"item_id": String(item_id)})
	picked_up = true
	monitoring = false
	visible = false
	return _finish_interaction(player, "picked_up", {
		"item_id": String(item_id),
		"amount": amount,
	})
