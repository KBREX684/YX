extends "res://scripts/objects/interactable.gd"

@export var is_open := false
@export var is_locked := false

@onready var _visual: Node2D = $PlaceholderDoor


func _ready() -> void:
	_sync_visual()


func interact(player: Node) -> Dictionary:
	if is_locked:
		return _finish_interaction(player, "locked")
	is_open = not is_open
	_sync_visual()
	return _finish_interaction(player, "opened" if is_open else "closed")


func _sync_visual() -> void:
	if _visual != null:
		_visual.rotation_degrees = -8.0 if is_open else 0.0
