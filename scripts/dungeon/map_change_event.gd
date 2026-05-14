extends Node2D
class_name MapChangeEvent
## MapChangeEvent —— P1 灰盒地图变化事件。
##
## 只移动同场景内的占位段，并通过 EventBus 发出规则事件占位。

signal triggered(event_id: StringName)

@export var event_id: StringName = &"event_corridor_stretch"
@export var target_path: NodePath
@export var offset: Vector2 = Vector2(120.0, 0.0)

var was_triggered := false


func trigger() -> bool:
	if was_triggered:
		return false
	was_triggered = true

	var target := get_node_or_null(target_path) as Node2D
	if target != null:
		target.position += offset

	triggered.emit(event_id)
	EventBus.rule_triggered.emit(String(event_id), {
		"kind": "map_change",
		"offset": offset,
	})
	return true
