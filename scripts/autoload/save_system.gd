extends Node
## SaveSystem —— 存档读写
##
## TASK-P0-3：仅声明接口骨架。
## 详细实现见 TASK-P4-*；测试覆盖见 docs/00-tech-constraints.md §九。
## 红线：使用 ResourceSaver 或 JSON；禁止 Pickle / 不可读二进制（§四.6）。

const SAVE_DIR := "user://saves/"
const DEFAULT_SLOT := "slot_0"


func _ready() -> void:
	push_warning("SaveSystem: skeleton only, behaviour not implemented (TASK-P0-3).")


## 保存当前游戏状态到指定存档槽。
func save_game(_slot: String = DEFAULT_SLOT) -> bool:
	push_warning("SaveSystem.save_game: not implemented")
	return false


## 从指定存档槽加载游戏状态。
func load_game(_slot: String = DEFAULT_SLOT) -> bool:
	push_warning("SaveSystem.load_game: not implemented")
	return false


## 列出所有可用存档槽。
func list_slots() -> Array[String]:
	push_warning("SaveSystem.list_slots: not implemented")
	return []


## 删除指定存档槽。
func delete_slot(_slot: String) -> bool:
	push_warning("SaveSystem.delete_slot: not implemented")
	return false
