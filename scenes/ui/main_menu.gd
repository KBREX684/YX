extends Control
## 占位主菜单 —— TASK-P0-3 验收用，保证项目启动无脚本红字。
## 后续将由 TASK-P5-* / UI 工作流替换为正式主菜单。

@export_file("*.tscn") var playtest_scene_path := "res://scenes/dungeon/micro_school_blockout.tscn"
@onready var _start_button: Button = $StartPlaytestButton


func _ready() -> void:
	print_rich("[color=cyan]YX[/color] placeholder main menu ready. Autoloads: %s" % [_list_autoloads()])
	if _start_button != null and not _start_button.pressed.is_connected(_on_start_button_pressed):
		_start_button.pressed.connect(_on_start_button_pressed)
		_start_button.grab_focus()


func _list_autoloads() -> Array[String]:
	var names: Array[String] = []
	for autoload_name in ["GameState", "EventBus", "SaveSystem", "AudioManager", "Config"]:
		if Engine.has_singleton(autoload_name) or get_tree().root.has_node(autoload_name):
			names.append(autoload_name)
	return names


func _on_start_button_pressed() -> void:
	if ResourceLoader.exists(playtest_scene_path):
		get_tree().change_scene_to_file(playtest_scene_path)
	else:
		push_error("Playtest scene missing: %s" % playtest_scene_path)
