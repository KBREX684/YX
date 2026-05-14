extends Node
## AudioManager —— 音频总控
##
## TASK-P0-3：声明 AudioBus 占位常量与播放接口骨架。
## 详见 docs/00-tech-constraints.md §六.4：3D 空间化音频强制启用，
## 心跳/手电/环境异响通过 AudioBus 分组以便动态混音。

## AudioBus 名称（与项目 AudioBus 资源中一致；目前为占位常量）。
const BUS_MASTER := "Master"
const BUS_MUSIC := "Music"
const BUS_SFX := "SFX"
const BUS_HEARTBEAT := "Heartbeat"
const BUS_FLASHLIGHT := "Flashlight"
const BUS_AMBIENT := "Ambience"


func _ready() -> void:
	pass


## 播放 BGM。stream 为 AudioStream 资源；fade_in 单位秒。
func play_bgm(_stream: AudioStream, _fade_in: float = 0.0) -> void:
	push_warning("AudioManager.play_bgm: not implemented")


## 在指定 2D 位置播放空间化音效（核心机制依赖此项）。
func play_sfx_2d(_stream: AudioStream, _position: Vector2, _bus: String = BUS_SFX) -> void:
	push_warning("AudioManager.play_sfx_2d: not implemented")


## 设置某条 AudioBus 的音量（dB）。
func set_bus_volume_db(_bus: String, _db: float) -> void:
	push_warning("AudioManager.set_bus_volume_db: not implemented")


## 停止所有音频（场景切换时调用）。
func stop_all() -> void:
	push_warning("AudioManager.stop_all: not implemented")
