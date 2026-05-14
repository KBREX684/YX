extends Node2D
class_name HeartbeatPlayer

@onready var _player: AudioStreamPlayer2D = $HeartbeatPlayer2D


func _ready() -> void:
	if not EventBus.pressure_changed.is_connected(apply_pressure_level):
		EventBus.pressure_changed.connect(apply_pressure_level)


func _exit_tree() -> void:
	if EventBus.pressure_changed.is_connected(apply_pressure_level):
		EventBus.pressure_changed.disconnect(apply_pressure_level)


func apply_pressure_level(level: float) -> void:
	var amount := clampf(level, 0.0, 1.0)
	_player.volume_db = lerpf(-36.0, -5.0, amount)
	_player.pitch_scale = lerpf(0.75, 1.55, amount)
	if amount > 0.1 and _player.stream != null and not _player.playing:
		_player.play()


func get_player() -> AudioStreamPlayer2D:
	return _player
