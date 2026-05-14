extends Node2D
class_name FirstEntryManifestTrigger

@export var target_path: NodePath
@export_range(0.1, 10.0, 0.1) var manifest_duration := 2.5
@export var auto_trigger_on_ready := true

var _has_triggered := false


func _ready() -> void:
	if auto_trigger_on_ready:
		call_deferred("trigger_once")


func trigger_once() -> bool:
	if _has_triggered:
		return false

	var target := _resolve_target()
	if target == null:
		push_warning("FirstEntryManifestTrigger target is missing: %s" % target_path)
		return false

	if target.has_method("show_apparition"):
		target.call("show_apparition", manifest_duration)
	elif target.has_method("manifest"):
		target.call("manifest", manifest_duration)
	else:
		push_warning("FirstEntryManifestTrigger target cannot manifest: %s" % target_path)
		return false

	_has_triggered = true
	return true


func has_triggered() -> bool:
	return _has_triggered


func _resolve_target() -> Node:
	var target := get_node_or_null(target_path)
	if target == null and owner != null:
		target = owner.get_node_or_null(target_path)
	return target
