extends RefCounted
class_name DeathFeedbackResolver

const FALLBACK_HINT := "未知规则导致了这次失败。先回基地整理线索，再从脚步声、光源或仪式顺序重新排查。"


func resolve(payload: Dictionary) -> Dictionary:
	var rule_id := String(payload.get("rule_id", payload.get("source_rule_id", ""))).strip_edges()
	var direct_hint := String(payload.get("learnable_hint", "")).strip_edges()
	if direct_hint != "":
		return _feedback(rule_id, direct_hint, false)
	if rule_id != "":
		var rule := _find_rule_by_id(rule_id)
		if rule != null:
			var hint := String(rule.get("learnable_hint")).strip_edges()
			if hint != "":
				return _feedback(rule_id, hint, false)
	return _feedback(rule_id, FALLBACK_HINT, true)


func _feedback(rule_id: String, hint: String, is_fallback: bool) -> Dictionary:
	return {
		"source_rule_id": rule_id,
		"learnable_hint": hint,
		"is_fallback": is_fallback,
	}


func _find_rule_by_id(rule_id: String) -> Resource:
	for path in _collect_tres_files(_rule_root()):
		var resource: Resource = ResourceLoader.load(path)
		if resource != null and String(resource.get("id")) == rule_id:
			return resource
	return null


func _collect_tres_files(root: String) -> Array[String]:
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


func _rule_root() -> String:
	return "res://" + "data/rules"
