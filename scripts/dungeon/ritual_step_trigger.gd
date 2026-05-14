extends Area2D
class_name RitualStepTrigger

@export var step_id: StringName = &""
@export var zone_id: StringName = &"ritual_room"
@export var action_id: StringName = &"place_anchors"
@export_multiline var placeholder_asset_note := "占位: 收容仪式交互点，后续替换为厚涂分层 PNG 与 2.5D Live 轻动画。"


func build_context(completed_steps: PackedStringArray = PackedStringArray()) -> Dictionary:
	return {
		"zone_id": String(zone_id),
		"source_action_id": action_id,
		"completed_steps": completed_steps,
		"trigger_step_id": String(step_id),
		"placeholder_asset_note": placeholder_asset_note,
	}
