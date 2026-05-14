extends Node
## SaveSystem —— Provider 注册式存档读写
##
## 架构：每个系统（GameState / ClueBook / ObjectiveResolver / SettlementCalculator …）
## 在 _ready 时通过 register_provider(id, save_callable, load_callable) 注册自己；
## SaveSystem 只负责 序列化/反序列化 JSON、版本管理、原子写入与槽位枚举。
##
## 文件结构（user://saves/<slot>.save.json）：
##   {
##     "version": 1,
##     "schema": "yx_save",
##     "timestamp": <unix>,
##     "slot": "slot_0",
##     "providers": { "<id>": <data>, ... }
##   }
##
## 红线：JSON 文本；写入前先写 .tmp，再 rename 替换避免半写文件。

signal slot_saved(slot: String)
signal slot_loaded(slot: String)
signal slot_deleted(slot: String)

const SAVE_DIR := "user://saves/"
const DEFAULT_SLOT := "slot_0"
const SAVE_EXT := ".save.json"
const CURRENT_VERSION := 1
const SCHEMA_ID := "yx_save"

var _providers: Dictionary = {} # id -> { "save": Callable, "load": Callable }


func _ready() -> void:
	_ensure_dir()


## 注册一个存档 Provider。
## save_callable: () -> Dictionary，返回该模块要持久化的纯数据。
## load_callable: (Dictionary) -> void，接收上次保存的数据并恢复状态。
func register_provider(id: String, save_callable: Callable, load_callable: Callable) -> void:
	if id.strip_edges() == "":
		push_error("SaveSystem.register_provider: empty id")
		return
	if not save_callable.is_valid() or not load_callable.is_valid():
		push_error("SaveSystem.register_provider(%s): invalid callable" % id)
		return
	_providers[id] = {"save": save_callable, "load": load_callable}


func unregister_provider(id: String) -> void:
	_providers.erase(id)


func has_provider(id: String) -> bool:
	return _providers.has(id)


## 保存所有注册 Provider 的状态到指定槽位。
func save_game(slot: String = DEFAULT_SLOT) -> bool:
	if not _ensure_dir():
		return false
	var payload := {
		"version": CURRENT_VERSION,
		"schema": SCHEMA_ID,
		"timestamp": int(Time.get_unix_time_from_system()),
		"slot": slot,
		"providers": _collect_provider_data(),
	}
	var json := JSON.stringify(payload, "\t")
	var target := _slot_path(slot)
	var tmp := target + ".tmp"
	var file := FileAccess.open(tmp, FileAccess.WRITE)
	if file == null:
		push_error("SaveSystem.save_game: cannot open %s (err=%d)" % [tmp, FileAccess.get_open_error()])
		return false
	file.store_string(json)
	file.close()
	# 原子替换：先删旧、再 rename。
	if FileAccess.file_exists(target):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(target))
	var rename_err := DirAccess.rename_absolute(
		ProjectSettings.globalize_path(tmp),
		ProjectSettings.globalize_path(target),
	)
	if rename_err != OK:
		# 退化：直接读 tmp 写入 target。
		var src := FileAccess.open(tmp, FileAccess.READ)
		var dst := FileAccess.open(target, FileAccess.WRITE)
		if src == null or dst == null:
			push_error("SaveSystem.save_game: rename + fallback failed")
			return false
		dst.store_string(src.get_as_text())
		src.close()
		dst.close()
		DirAccess.remove_absolute(ProjectSettings.globalize_path(tmp))
	slot_saved.emit(slot)
	return true


## 从指定存档槽加载，分发到各 Provider。
func load_game(slot: String = DEFAULT_SLOT) -> bool:
	var path := _slot_path(slot)
	if not FileAccess.file_exists(path):
		push_warning("SaveSystem.load_game: %s not found" % path)
		return false
	var text := FileAccess.get_file_as_string(path)
	var parsed: Variant = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("SaveSystem.load_game: %s is not valid JSON object" % path)
		return false
	var data: Dictionary = parsed
	var version := int(data.get("version", 0))
	if version > CURRENT_VERSION:
		push_warning("SaveSystem.load_game: save version %d > current %d (forward-incompatible)" % [version, CURRENT_VERSION])
	var providers: Dictionary = data.get("providers", {})
	for id in _providers.keys():
		if not providers.has(id):
			continue
		var entry: Dictionary = _providers[id]
		var load_callable: Callable = entry.get("load")
		if load_callable.is_valid():
			load_callable.call(providers[id])
	slot_loaded.emit(slot)
	return true


## 列出所有可用存档槽（按修改时间倒序）。
func list_slots() -> Array[String]:
	var out: Array[String] = []
	var dir := DirAccess.open(SAVE_DIR)
	if dir == null:
		return out
	dir.list_dir_begin()
	var name := dir.get_next()
	while name != "":
		if not dir.current_is_dir() and name.ends_with(SAVE_EXT):
			out.append(name.replace(SAVE_EXT, ""))
		name = dir.get_next()
	dir.list_dir_end()
	return out


func delete_slot(slot: String) -> bool:
	var path := _slot_path(slot)
	if not FileAccess.file_exists(path):
		return false
	var err := DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	if err == OK:
		slot_deleted.emit(slot)
		return true
	push_error("SaveSystem.delete_slot(%s): err=%d" % [slot, err])
	return false


func slot_exists(slot: String) -> bool:
	return FileAccess.file_exists(_slot_path(slot))


func _slot_path(slot: String) -> String:
	return SAVE_DIR.path_join(slot + SAVE_EXT)


func _ensure_dir() -> bool:
	if DirAccess.dir_exists_absolute(SAVE_DIR):
		return true
	var err := DirAccess.make_dir_recursive_absolute(SAVE_DIR)
	if err != OK:
		push_error("SaveSystem: cannot create %s (err=%d)" % [SAVE_DIR, err])
		return false
	return true


func _collect_provider_data() -> Dictionary:
	var out := {}
	for id in _providers.keys():
		var entry: Dictionary = _providers[id]
		var save_callable: Callable = entry.get("save")
		if not save_callable.is_valid():
			continue
		var value: Variant = save_callable.call()
		# 强制转换为可序列化的纯数据类型。
		if typeof(value) == TYPE_DICTIONARY or typeof(value) == TYPE_ARRAY:
			out[id] = value
		else:
			out[id] = {"value": value}
	return out
