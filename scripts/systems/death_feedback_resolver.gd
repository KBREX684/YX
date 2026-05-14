extends RefCounted
class_name DeathFeedbackResolver

## DeathFeedbackResolver —— 死亡反馈解析器
##
## 行为：根据死亡 context 中的 rule_id 在 data/rules 中查找对应规则的 learnable_hint。
## 性能：rule_id -> learnable_hint 的索引在首次解析时一次性构建，并以 static 形式
## 缓存到整个进程生命周期；后续死亡只查 dict，不再扫盘。
## 可通过 invalidate_cache() 强制重建（编辑期热重载）。

const FALLBACK_HINT := "未知规则导致了这次失败。先回基地整理线索，再从脚步声、光源或仪式顺序重新排查。"
const RULE_ROOT := "res://data/rules"

static var _hint_cache: Dictionary = {} # rule_id -> hint
static var _cache_built: bool = false


static func invalidate_cache() -> void:
	_hint_cache.clear()
	_cache_built = false


static func _ensure_cache() -> void:
	if _cache_built:
		return
	_hint_cache.clear()
	for path in _collect_tres_files(RULE_ROOT):
		var resource: Resource = ResourceLoader.load(path)
		if resource == null:
			continue
		var id := String(resource.get("id")).strip_edges()
		var hint := String(resource.get("learnable_hint")).strip_edges()
		if id == "" or hint == "":
			continue
		_hint_cache[id] = hint
	_cache_built = true


func resolve(payload: Dictionary) -> Dictionary:
	var rule_id := String(payload.get("rule_id", payload.get("source_rule_id", ""))).strip_edges()
	var direct_hint := String(payload.get("learnable_hint", "")).strip_edges()
	if direct_hint != "":
		return _feedback(rule_id, direct_hint, false)
	if rule_id != "":
		_ensure_cache()
		if _hint_cache.has(rule_id):
			return _feedback(rule_id, String(_hint_cache[rule_id]), false)
	return _feedback(rule_id, FALLBACK_HINT, true)


func _feedback(rule_id: String, hint: String, is_fallback: bool) -> Dictionary:
	return {
		"source_rule_id": rule_id,
		"learnable_hint": hint,
		"is_fallback": is_fallback,
	}


static func _collect_tres_files(root: String) -> Array[String]:
	var out: Array[String] = []
	var dir := DirAccess.open(root)
	if dir == null:
		return out
	dir.list_dir_begin()
	var name := dir.get_next()
	while name != "":
		if name.begins_with("."):
			name = dir.get_next()
			continue
		var full_path := root.path_join(name)
		if dir.current_is_dir():
			out.append_array(_collect_tres_files(full_path))
		elif name.ends_with(".tres"):
			out.append(full_path)
		name = dir.get_next()
	dir.list_dir_end()
	return out
