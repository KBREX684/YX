extends Control
class_name SettlementScreen

@export var auto_subscribe_event_bus := true
@export var placeholder_asset_note := "Placeholder settlement UI for P3-3. Replace with painterly 2.5D Live result art later."

@onready var completion_type_label: Label = $Margin/Content/CompletionTypeLabel
@onready var resource_value_label: Label = $Margin/Content/ResourceValueLabel
@onready var origin_value_label: Label = $Margin/Content/OriginValueLabel
@onready var archive_value_label: Label = $Margin/Content/ArchiveValueLabel
@onready var base_delta_label: Label = $Margin/Content/BaseDeltaLabel
@onready var pollution_label: Label = $Margin/Content/PollutionValueLabel


func _ready() -> void:
	visible = false
	if auto_subscribe_event_bus:
		_subscribe_event_bus()


func _exit_tree() -> void:
	if EventBus.settlement_ready.is_connected(display_settlement):
		EventBus.settlement_ready.disconnect(display_settlement)


func display_settlement(payload: Dictionary) -> void:
	visible = true
	var resources: Dictionary = payload.get("resource_summary", {})
	var origin: Dictionary = payload.get("origin_output", {})
	var archive: Dictionary = payload.get("archive_update", {})
	var base_delta: Dictionary = payload.get("base_resource_delta", {})
	var pollution: Dictionary = payload.get("pollution_delta", {})

	completion_type_label.text = "Route: %s" % String(payload.get("settlement_type", "unknown"))
	resource_value_label.text = "Resources: %d total | S %d / P %d / G %d / I %d | Lost %d" % [
		int(resources.get("total_awarded", 0)),
		int(resources.get("survival", 0)),
		int(resources.get("puzzle", 0)),
		int(resources.get("growth", 0)),
		int(resources.get("intel", 0)),
		int(resources.get("lost", 0)),
	]
	origin_value_label.text = "Origin: %s / %s / %s" % [
		String(origin.get("quality", "none")),
		String(origin.get("stability", "none")),
		String(origin.get("route_affinity", "none")),
	]
	archive_value_label.text = "Archive: +%d entries | %d%%" % [
		int(archive.get("entries_added", 0)),
		int(archive.get("completion_percent", 0)),
	]
	base_delta_label.text = "Base placeholder materials: %+d | lost %d" % [
		int(base_delta.get("placeholder_materials", 0)),
		int(base_delta.get("lost", 0)),
	]
	pollution_label.text = "Pollution: player %.2f | base %.2f" % [
		float(pollution.get("player", 0.0)),
		float(pollution.get("base", 0.0)),
	]


func _subscribe_event_bus() -> void:
	if not EventBus.settlement_ready.is_connected(display_settlement):
		EventBus.settlement_ready.connect(display_settlement)
