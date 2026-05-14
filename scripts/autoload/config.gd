extends Node
## Config —— 运行时配置读取
##
## TASK-P0-3：通过 ConfigFile 读取 res://config/default.cfg，
## 仅暴露 get/set/save 接口骨架；真实参数表在后续阶段补全。

const DEFAULT_CONFIG_PATH := "res://config/default.cfg"
const USER_CONFIG_PATH := "user://override.cfg"

var _file: ConfigFile = ConfigFile.new()
var _loaded: bool = false


func _ready() -> void:
	_load_defaults()


func _load_defaults() -> void:
	var err := _file.load(DEFAULT_CONFIG_PATH)
	if err != OK:
		push_warning("Config: default.cfg not found at %s (err=%d)" % [DEFAULT_CONFIG_PATH, err])
		_loaded = false
		return
	# 若存在用户覆盖文件，叠加加载。
	if FileAccess.file_exists(USER_CONFIG_PATH):
		var override := ConfigFile.new()
		if override.load(USER_CONFIG_PATH) == OK:
			for section in override.get_sections():
				for key in override.get_section_keys(section):
					_file.set_value(section, key, override.get_value(section, key))
	_loaded = true


## 读取配置值。section/key 不存在时返回 default。
func get_value(section: String, key: String, default: Variant = null) -> Variant:
	if not _loaded:
		return default
	return _file.get_value(section, key, default)


## 写入配置值（仅内存，需调用 save() 持久化到 user:// 覆盖文件）。
func set_value(section: String, key: String, value: Variant) -> void:
	_file.set_value(section, key, value)


## 把当前内存配置保存到 user://override.cfg。
func save() -> Error:
	return _file.save(USER_CONFIG_PATH)


func is_loaded() -> bool:
	return _loaded
