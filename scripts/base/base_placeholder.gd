extends Node2D
class_name BasePlaceholder

@export var placeholder_asset_note := "Placeholder base room for P3-4. Replace with painterly 2.5D Live base layers in P5."

@onready var hint_label: Label = $CanvasLayer/DeathFeedbackPanel/Margin/Content/HintLabel
@onready var loss_label: Label = $CanvasLayer/DeathFeedbackPanel/Margin/Content/LossLabel


func _ready() -> void:
	display_death_feedback(GameState.get_last_death_feedback())


func display_death_feedback(payload: Dictionary) -> void:
	var hint := String(payload.get("learnable_hint", ""))
	if hint.strip_edges() == "":
		hint = "基地暂时接收了你。死亡原因未知，先整理线索。"
	var loss: Dictionary = payload.get("loss", {})
	hint_label.text = hint
	loss_label.text = "Carried lost %d | Loot returned %d | Loot lost %d" % [
		int(loss.get("carried_in_lost", 0)),
		int(loss.get("looted_returned", 0)),
		int(loss.get("looted_lost", 0)),
	]
