extends "res://scripts/objects/interactable.gd"

@export var spot_id: StringName = &"hide_locker_a"
@export_enum("locker", "shadow") var spot_kind := "locker"


func interact(player: Node) -> Dictionary:
	return _finish_interaction(player, "hidden", {
		"spot_id": String(spot_id),
		"spot_kind": spot_kind,
	})
