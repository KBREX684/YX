extends Area2D
class_name PlayerInteractionSensor

var _candidates: Array[Node] = []


func _ready() -> void:
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)


func get_nearest_interactable(origin: Vector2, required_result: String = "") -> Node:
	_prune_candidates()
	var nearest: Node = null
	var nearest_distance := INF
	for candidate in _candidates:
		if not candidate.has_method("interact"):
			continue
		if required_result != "" and String(candidate.get("interaction_result")) != required_result:
			continue
		var node_2d := candidate as Node2D
		if node_2d == null:
			continue
		var distance := origin.distance_squared_to(node_2d.global_position)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest = candidate
	return nearest


func _on_area_entered(area: Area2D) -> void:
	if area.has_method("interact") and not _candidates.has(area):
		_candidates.append(area)


func _on_area_exited(area: Area2D) -> void:
	_candidates.erase(area)


func _prune_candidates() -> void:
	_candidates = _candidates.filter(func(candidate: Node) -> bool: return is_instance_valid(candidate))
