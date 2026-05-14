extends Node
## AudioManager —— 音频总控
##
## 负责：
##   - 启动时校验所有声明的 AudioBus 是否存在，缺失则 push_error。
##   - 提供 BGM、2D 空间音效、Bus 音量与全停接口。
##   - 维护少量复用 AudioStreamPlayer 池避免每次 new。
##
## 红线：所有依赖空间感的音效（心跳/手电脚步/广播）必须经 play_sfx_2d 使用 AudioStreamPlayer2D。

const BUS_MASTER := "Master"
const BUS_MUSIC := "Music"
const BUS_SFX := "SFX"
const BUS_HEARTBEAT := "Heartbeat"
const BUS_FLASHLIGHT := "Flashlight"
const BUS_AMBIENT := "Ambience"

const REQUIRED_BUSSES: Array[String] = [
	BUS_MASTER, BUS_MUSIC, BUS_SFX, BUS_HEARTBEAT, BUS_FLASHLIGHT, BUS_AMBIENT,
]

const SFX_POOL_SIZE := 8

var _bgm_player: AudioStreamPlayer
var _sfx_pool: Array[AudioStreamPlayer2D] = []
var _missing_busses: PackedStringArray = PackedStringArray()


func _ready() -> void:
	_validate_busses()
	_bgm_player = AudioStreamPlayer.new()
	_bgm_player.bus = BUS_MUSIC
	_bgm_player.name = "BGMPlayer"
	add_child(_bgm_player)
	for i in SFX_POOL_SIZE:
		var p := AudioStreamPlayer2D.new()
		p.bus = BUS_SFX
		p.name = "Sfx2D_%d" % i
		add_child(p)
		_sfx_pool.append(p)


func play_bgm(stream: AudioStream, fade_in: float = 0.0) -> void:
	if stream == null or _bgm_player == null:
		return
	_bgm_player.stream = stream
	if fade_in > 0.0:
		_bgm_player.volume_db = -40.0
		_bgm_player.play()
		var tween := create_tween()
		tween.tween_property(_bgm_player, "volume_db", 0.0, fade_in)
	else:
		_bgm_player.volume_db = 0.0
		_bgm_player.play()


func stop_bgm(fade_out: float = 0.0) -> void:
	if _bgm_player == null or not _bgm_player.playing:
		return
	if fade_out > 0.0:
		var tween := create_tween()
		tween.tween_property(_bgm_player, "volume_db", -40.0, fade_out)
		tween.tween_callback(_bgm_player.stop)
	else:
		_bgm_player.stop()


## 在指定 2D 位置播放空间化音效。返回实际播放器，便于调用方控制（pitch、stop）。
func play_sfx_2d(stream: AudioStream, position: Vector2, bus: String = BUS_SFX) -> AudioStreamPlayer2D:
	if stream == null:
		return null
	var player := _acquire_sfx_player()
	if player == null:
		return null
	player.bus = _safe_bus(bus)
	player.stream = stream
	player.global_position = position
	player.pitch_scale = 1.0
	player.volume_db = 0.0
	player.play()
	return player


func set_bus_volume_db(bus: String, db: float) -> void:
	var idx := AudioServer.get_bus_index(bus)
	if idx == -1:
		push_warning("AudioManager.set_bus_volume_db: missing bus '%s'" % bus)
		return
	AudioServer.set_bus_volume_db(idx, db)


func set_bus_mute(bus: String, muted: bool) -> void:
	var idx := AudioServer.get_bus_index(bus)
	if idx == -1:
		return
	AudioServer.set_bus_mute(idx, muted)


func stop_all() -> void:
	if _bgm_player != null:
		_bgm_player.stop()
	for p in _sfx_pool:
		if p != null and p.playing:
			p.stop()


func is_bus_available(bus: String) -> bool:
	return AudioServer.get_bus_index(bus) != -1


func _validate_busses() -> void:
	_missing_busses.clear()
	for bus in REQUIRED_BUSSES:
		if AudioServer.get_bus_index(bus) == -1:
			_missing_busses.append(bus)
	if not _missing_busses.is_empty():
		# 缺失时降级到 Master（见 _safe_bus），不阻塞启动，但记录 warning 便于配置补全。
		push_warning("AudioManager: missing AudioBus(es): %s. Falling back to Master for those. Configure default_bus_layout in project.godot to silence." % ", ".join(_missing_busses))


func _safe_bus(bus: String) -> String:
	if AudioServer.get_bus_index(bus) == -1:
		return BUS_MASTER
	return bus


func _acquire_sfx_player() -> AudioStreamPlayer2D:
	for p in _sfx_pool:
		if p != null and not p.playing:
			return p
	# 全部繁忙：复用最早的一个。
	if not _sfx_pool.is_empty():
		var first := _sfx_pool[0]
		first.stop()
		return first
	return null
