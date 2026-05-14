extends Resource
class_name ClueResource

@export var clue_id: String = ""
@export_enum("escape", "kill", "contain", "world") var route: String = "escape"
@export_enum("text", "environment", "sound", "behavior", "item", "audio_text") var clue_kind: String = "text"
@export var linked_rule_ids: PackedStringArray = PackedStringArray()
@export var dialogic_timeline_id: StringName = &""
@export_file("*.dtl") var dialogic_timeline_path: String = ""
@export_multiline var archive_summary: String = ""
@export var is_behavior_verification: bool = false
@export var verifies_rule_id: String = ""
@export_enum("low", "medium", "high") var risk_band: String = "low"
@export_multiline var placeholder_asset_note: String = ""


func is_valid() -> bool:
	return (
		clue_id.strip_edges() != ""
		and route.strip_edges() != ""
		and clue_kind.strip_edges() != ""
		and dialogic_timeline_path.strip_edges() != ""
		and archive_summary.strip_edges() != ""
	)
