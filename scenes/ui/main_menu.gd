extends Control
## 占位主菜单 —— TASK-P0-3 验收用，保证项目启动无脚本红字。
## 后续将由 TASK-P5-* / UI 工作流替换为正式主菜单。


func _ready() -> void:
	print_rich("[color=cyan]YX[/color] placeholder main menu ready. Autoloads: %s" % [_list_autoloads()])


func _list_autoloads() -> Array[String]:
	var names: Array[String] = []
	for autoload_name in ["GameState", "EventBus", "SaveSystem", "AudioManager", "Config"]:
		if Engine.has_singleton(autoload_name) or get_tree().root.has_node(autoload_name):
			names.append(autoload_name)
	return names
