extends CanvasLayer
class_name PressureHud

@onready var _heartbeat_vignette: ColorRect = $Root/HeartbeatVignette
@onready var _flashlight_flicker: ColorRect = $Root/FlashlightFlicker
@onready var _sanity_overlay: ColorRect = $Root/SanityDistortOverlay


func _ready() -> void:
	call_deferred("_bind_default_pressure_level")


func bind_pressure_level(pressure_level: Node) -> void:
	if pressure_level != null and pressure_level.has_signal("feedback_changed") and not pressure_level.feedback_changed.is_connected(apply_feedback_snapshot):
		pressure_level.feedback_changed.connect(apply_feedback_snapshot)
		if pressure_level.has_method("get_feedback_snapshot"):
			apply_feedback_snapshot(pressure_level.get_feedback_snapshot())


func apply_feedback_snapshot(snapshot: Dictionary) -> void:
	var heartbeat := float(snapshot.get("heartbeat_intensity", 0.0))
	var flicker_hz := float(snapshot.get("flashlight_flicker_hz", 0.0))
	var screen_fx := float(snapshot.get("screen_fx_intensity", 0.0))
	_heartbeat_vignette.color = Color(0.45, 0.02, 0.02, clampf(heartbeat * 0.28, 0.0, 0.35))
	_flashlight_flicker.color = Color(1.0, 0.92, 0.72, clampf(flicker_hz / 40.0, 0.0, 0.22))
	var material := _sanity_overlay.material as ShaderMaterial
	if material != null:
		material.set_shader_parameter("sanity_intensity", screen_fx)


func _bind_default_pressure_level() -> void:
	var pressure_level := get_tree().get_first_node_in_group("pressure_level")
	bind_pressure_level(pressure_level)
