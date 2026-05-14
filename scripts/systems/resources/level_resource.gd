extends Resource
class_name LevelResource
## LevelResource —— 关卡数据契约（P1 起）。

@export var id: String = ""
@export var display_name: String = ""
@export var scene_id: String = ""
@export var scene_path: String = ""
@export var room_ids: PackedStringArray = []
@export var map_event_ids: PackedStringArray = []
@export var entrance_id: String = ""
@export var exit_id: String = ""
