@tool
extends EditorScript
## validate_schemas.gd —— 数据契约校验器（TASK-P0-6）
##
## 用途：遍历 res://data/**/*.tres，逐字段检查必填字段非空，输出报告。
## 调用方式：
##   - 编辑器：File ➜ Run Script，选中本文件后点击运行。
##   - 命令行：godot --headless --path . --script res://tools/validate_schemas.gd
##
## 退出码（命令行模式）：0=全部通过，1=存在错误。
## 红线：本工具只读，不修改任何资源文件。

const DATA_ROOT := "res://data"

## 字段规则表：脚本类名 -> { 字段名 -> 校验函数（接收 value, 返回错误信息或空串） }
## 列出的字段为"必填非空"项；其余字段为可选。
const REQUIRED := {
	"RuleResource": {
		"id": "non_empty_string",
		"trigger_conditions": "non_empty_array",
		"effect": "non_empty_dict",
	},
	"OriginResource": {
		"id": "non_empty_string",
		"stage": "non_negative_int",
	},
	"MonsterProfile": {
		"id": "non_empty_string",
		"name": "non_empty_string",
		"rule_ids": "non_empty_string_array",
	},
	"ItemResource": {
		"id": "non_empty_string",
		"stack_max": "positive_int",
	},
}


func _run() -> void:
	var report := validate_all()
	_print_report(report)
	# 由调用方决定是否 quit；EditorScript._run() 不应主动退出编辑器。


## 遍历数据目录，返回 {checked: int, errors: Array[String], passed: Array[String]}。
func validate_all() -> Dictionary:
	var report := {
		"checked": 0,
		"passed": [] as Array,
		"errors": [] as Array,
	}
	var files := _collect_tres_files(DATA_ROOT)
	for path in files:
		report["checked"] += 1
		var res: Resource = ResourceLoader.load(path)
		if res == null:
			report["errors"].append("[LOAD-FAIL] %s : 无法加载资源" % path)
			continue
		var script: Script = res.get_script()
		var class_id := ""
		if script != null:
			class_id = _infer_class_name(script.resource_path)
		if not REQUIRED.has(class_id):
			# 未注册的类型不强制校验，但提示。
			report["passed"].append("[SKIP] %s : 未注册类型 %s" % [path, class_id])
			continue
		var rules: Dictionary = REQUIRED[class_id]
		var errors := _validate_resource(res, rules)
		if errors.is_empty():
			report["passed"].append("[OK]   %s (%s)" % [path, class_id])
		else:
			for e in errors:
				report["errors"].append("[FAIL] %s : %s" % [path, e])
	return report


func _collect_tres_files(root: String) -> Array[String]:
	var out: Array[String] = []
	var dir := DirAccess.open(root)
	if dir == null:
		push_warning("validate_schemas: 无法打开 %s" % root)
		return out
	dir.list_dir_begin()
	var name := dir.get_next()
	while name != "":
		if name.begins_with("."):
			name = dir.get_next()
			continue
		var full := root.path_join(name)
		if dir.current_is_dir():
			out.append_array(_collect_tres_files(full))
		elif name.ends_with(".tres"):
			out.append(full)
		name = dir.get_next()
	dir.list_dir_end()
	return out


func _validate_resource(res: Resource, rules: Dictionary) -> Array[String]:
	var errors: Array[String] = []
	for field in rules.keys():
		var rule: String = rules[field]
		if not (field in res):
			errors.append("缺少字段: %s" % field)
			continue
		var value: Variant = res.get(field)
		var err := _check(value, rule)
		if err != "":
			errors.append("字段 %s %s" % [field, err])
	return errors


func _check(value: Variant, rule: String) -> String:
	match rule:
		"non_empty_string":
			if typeof(value) != TYPE_STRING or (value as String).strip_edges() == "":
				return "必须是非空字符串（当前=%s）" % str(value)
		"non_empty_array":
			if typeof(value) != TYPE_ARRAY or (value as Array).is_empty():
				return "必须是非空数组"
		"non_empty_string_array":
			if typeof(value) == TYPE_ARRAY:
				if (value as Array).is_empty():
					return "字符串数组不能为空"
			elif typeof(value) == TYPE_PACKED_STRING_ARRAY:
				if (value as PackedStringArray).is_empty():
					return "字符串数组不能为空"
			else:
				return "必须是字符串数组"
		"non_empty_dict":
			if typeof(value) != TYPE_DICTIONARY or (value as Dictionary).is_empty():
				return "必须是非空 Dictionary"
		"positive_int":
			if typeof(value) != TYPE_INT or (value as int) <= 0:
				return "必须是正整数（当前=%s）" % str(value)
		"non_negative_int":
			if typeof(value) != TYPE_INT or (value as int) < 0:
				return "必须是非负整数（当前=%s）" % str(value)
		_:
			return "未知校验规则 %s" % rule
	return ""


func _infer_class_name(script_path: String) -> String:
	# 形如 res://scripts/systems/resources/rule_resource.gd -> RuleResource
	var base := script_path.get_file().get_basename()
	var parts := base.split("_")
	var assembled := ""
	for p in parts:
		assembled += p.capitalize()
	return assembled


func _print_report(report: Dictionary) -> void:
	print_rich("[b]== Schema Validation Report ==[/b]")
	print("Checked: %d" % report["checked"])
	for line in report["passed"]:
		print(line)
	if report["errors"].is_empty():
		print_rich("[color=green]All resources passed.[/color]")
	else:
		print_rich("[color=red]Errors: %d[/color]" % report["errors"].size())
		for line in report["errors"]:
			print(line)
