extends Node
## Config —— 运行时配置读取
##
## 从 res://config/default.cfg 加载基线，再叠加 user://override.cfg。
## 若 user override 损坏，自动备份为 .bak 并回退默认值，避免单文件损坏导致游戏起不来。

const DEFAULT_CONFIG_PATH := "res://config/default.cfg"
const USER_CONFIG_PATH := "user://override.cfg"
const CORRUPT_BACKUP_SUFFIX := ".bak"

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
	if FileAccess.file_exists(USER_CONFIG_PATH):
		var override := ConfigFile.new()
		var override_err := override.load(USER_CONFIG_PATH)
		if override_err == OK:
			for section in override.get_sections():
				for key in override.get_section_keys(section):
					_file.set_value(section, key, override.get_value(section, key))
		else:
			_quarantine_corrupt_override(override_err)
	_loaded = true


func _quarantine_corrupt_override(err: int) -> void:
	var backup_path := USER_CONFIG_PATH + CORRUPT_BACKUP_SUFFIX
	push_warning("Config: %s load failed (err=%d). Moving to %s and using defaults." % [USER_CONFIG_PATH, err, backup_path])
	# 先删除已有备份避免冲突，再 rename。
	if FileAccess.file_exists(backup_path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(backup_path))
	var rename_err := DirAccess.rename_absolute(
		ProjectSettings.globalize_path(USER_CONFIG_PATH),
		ProjectSettings.globalize_path(backup_path),
	)
	if rename_err != OK:
		# 退化：直接删除损坏文件。
		DirAccess.remove_absolute(ProjectSettings.globalize_path(USER_CONFIG_PATH))


func get_value(section: String, key: String, default: Variant = null) -> Variant:
	if not _loaded:
		return default
	return _file.get_value(section, key, default)


func set_value(section: String, key: String, value: Variant) -> void:
	_file.set_value(section, key, value)


func save() -> Error:
	return _file.save(USER_CONFIG_PATH)


func is_loaded() -> bool:
	return _loaded
