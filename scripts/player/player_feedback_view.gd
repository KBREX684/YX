extends Node
class_name PlayerFeedbackView

@export var flashlight_beam_path := NodePath("../FlashlightBeam")
@export var body_visual_path := NodePath("../PlaceholderBody")
@export var feedback_label_path := NodePath("../FeedbackLabel")

@onready var _flashlight_beam: CanvasItem = get_node_or_null(flashlight_beam_path)
@onready var _body_visual: CanvasItem = get_node_or_null(body_visual_path)
@onready var _feedback_label: Label = get_node_or_null(feedback_label_path)


func sync_flashlight(enabled: bool) -> void:
	if _flashlight_beam != null:
		_flashlight_beam.visible = enabled


func sync_state(state: StringName, is_hidden: bool) -> void:
	if _body_visual == null:
		return
	_body_visual.scale = Vector2(1.0, 0.7) if state == &"crouch" else Vector2.ONE
	_body_visual.modulate = Color(0.55, 0.75, 1.0, 0.42) if is_hidden else Color.WHITE


func show_message(text: String) -> void:
	if _feedback_label == null:
		return
	_feedback_label.text = text
	_feedback_label.visible = text != ""


func show_interaction(payload: Dictionary) -> void:
	match String(payload.get("result", "")):
		"read":
			show_message(String(payload.get("text", "已阅读占位线索")))
		"hidden":
			show_message("躲藏中：再按 H 退出")
		"picked_up":
			show_message("拾取：%s x%s" % [payload.get("item_id", ""), payload.get("amount", 1)])
		_:
			show_message("交互：%s" % String(payload.get("result", "done")))
