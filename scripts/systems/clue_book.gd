extends Node
class_name ClueBook

const RESOURCE_SCHEME := "res:"
const CLUE_ROOT_FOLDER := "data"
const CLUE_FOLDER := "clues"

signal clue_recorded(clue_id: String)
signal clue_verified(clue_id: String, label: String)

@export var clue_resources: Array[Resource] = []
@export var auto_subscribe_event_bus := true

var _clue_by_id: Dictionary = {}
var _known_clue_ids: PackedStringArray = PackedStringArray()
var _verified_clue_labels: Dictionary = {}


func _ready() -> void:
	add_to_group("clue_book")
	if clue_resources.is_empty():
		clue_resources.assign(_load_clues_from_directory(_default_clue_directory()))
	rebuild_index()
	_sync_from_game_state()
	if auto_subscribe_event_bus:
		_subscribe_event_bus()


func _exit_tree() -> void:
	if EventBus.clue_unlocked.is_connected(_on_clue_unlocked):
		EventBus.clue_unlocked.disconnect(_on_clue_unlocked)
	if EventBus.rule_triggered.is_connected(_on_rule_triggered):
		EventBus.rule_triggered.disconnect(_on_rule_triggered)


func rebuild_index() -> void:
	_clue_by_id.clear()
	for clue in clue_resources:
		if clue == null:
			continue
		var id: String = String(clue.get("clue_id")).strip_edges()
		if id != "":
			_clue_by_id[id] = clue


func register_clue(clue_id: String) -> bool:
	var id := clue_id.strip_edges()
	if id == "":
		return false
	if _known_clue_ids.has(id):
		return false
	_known_clue_ids.append(id)
	GameState.record_clue(id)
	clue_recorded.emit(id)
	var clue: Resource = get_clue(id)
	var route := &"unknown"
	if clue != null:
		route = StringName(String(clue.get("route")))
	EventBus.clue_decoded.emit(id, route)
	return true


func has_clue(clue_id: String) -> bool:
	return _known_clue_ids.has(clue_id.strip_edges())


func get_clue(clue_id: String) -> Resource:
	return _clue_by_id.get(clue_id.strip_edges(), null)


func get_known_clue_ids() -> PackedStringArray:
	var copy := PackedStringArray()
	for clue_id in _known_clue_ids:
		copy.append(clue_id)
	return copy


func get_route_completion(route: String) -> Dictionary:
	var total := 0
	var known := 0
	for clue in clue_resources:
		if clue == null or String(clue.get("route")) != route:
			continue
		total += 1
		if has_clue(String(clue.get("clue_id"))):
			known += 1
	return {
		"route": route,
		"known": known,
		"total": total,
		"ratio": 0.0 if total == 0 else float(known) / float(total),
	}


func get_display_text(clue_id: String, reliability: float = -1.0) -> String:
	var clue: Resource = get_clue(clue_id)
	if clue == null:
		return ""
	var effective_reliability := reliability
	if effective_reliability < 0.0:
		effective_reliability = _current_clue_reliability()
	return _apply_reliability(String(clue.get("archive_summary")), effective_reliability)


func is_clue_verified(clue_id: String) -> bool:
	return _verified_clue_labels.has(clue_id.strip_edges())


func get_verification_label(clue_id: String) -> String:
	return String(_verified_clue_labels.get(clue_id.strip_edges(), ""))


func _subscribe_event_bus() -> void:
	if not EventBus.clue_unlocked.is_connected(_on_clue_unlocked):
		EventBus.clue_unlocked.connect(_on_clue_unlocked)
	if not EventBus.rule_triggered.is_connected(_on_rule_triggered):
		EventBus.rule_triggered.connect(_on_rule_triggered)


func _on_clue_unlocked(clue_id: String) -> void:
	register_clue(clue_id)


func _on_rule_triggered(rule_id: String, context: Dictionary) -> void:
	var effect: Dictionary = context.get("rule_effect", {})
	if String(effect.get("type", "")) != "clue_verification":
		return
	var clue_id := String(effect.get("clue_id", "")).strip_edges()
	if clue_id == "":
		return
	var label := String(effect.get("verified_label", ""))
	if label.strip_edges() == "":
		label = "verified:%s" % rule_id
	_verified_clue_labels[clue_id] = label
	clue_verified.emit(clue_id, label)


func _sync_from_game_state() -> void:
	for clue_id in GameState.known_clue_ids:
		if not _known_clue_ids.has(clue_id):
			_known_clue_ids.append(clue_id)


func _current_clue_reliability() -> float:
	var tree := get_tree()
	if tree == null:
		return 1.0
	var pressure := tree.get_first_node_in_group("pressure_level")
	if pressure != null and pressure.has_method("get_clue_reliability"):
		return float(pressure.call("get_clue_reliability"))
	return 1.0


func _apply_reliability(text: String, reliability: float) -> String:
	if reliability >= 0.75:
		return text
	if reliability >= 0.5:
		return "[干扰] %s" % text
	return "[干扰] 文字边缘出现重影：%s" % text


func _load_clues_from_directory(directory_path: String) -> Array[Resource]:
	var loaded: Array[Resource] = []
	var dir := DirAccess.open(directory_path)
	if dir == null:
		return loaded
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".tres"):
			var resource := ResourceLoader.load(directory_path.path_join(file_name))
			if resource != null and _is_clue_resource(resource):
				loaded.append(resource)
		file_name = dir.get_next()
	dir.list_dir_end()
	loaded.sort_custom(func(a: Resource, b: Resource) -> bool: return String(a.get("clue_id")) < String(b.get("clue_id")))
	return loaded


func _default_clue_directory() -> String:
	return "%s//%s/%s" % [RESOURCE_SCHEME, CLUE_ROOT_FOLDER, CLUE_FOLDER]


func _is_clue_resource(resource: Resource) -> bool:
	return (
		_has_resource_property(resource, "clue_id")
		and _has_resource_property(resource, "route")
		and _has_resource_property(resource, "dialogic_timeline_path")
	)


func _has_resource_property(resource: Resource, property_name: String) -> bool:
	for property in resource.get_property_list():
		if property.get("name", "") == property_name:
			return true
	return false
