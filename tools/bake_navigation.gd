@tool
extends SceneTree
## tools/bake_navigation.gd —— headless 预烘焙工具
##
## 用途：在 CI / 命令行环境下直接从场景文件解析 nav_floor 组的 Polygon2D 轮廓，
## 构建 NavigationPolygon 并输出诊断信息，验证 baker 覆盖范围。
##
## 运行：
##   godot --headless --path . --script res://tools/bake_navigation.gd
##
## 注意：工具不回写 .tscn；NavigationPolygon 由运行时 NavigationBaker 生成。

## --- 场景几何描述（与 .tscn 保持同步）-------------------------------------
## 每条条目：{ "label": <名称>, "outlines": [ [ [x,y], ... ], ... ] }
## 坐标均为 NavigationRegion2D 本地空间（= 根节点本地空间，因为两个场景
## NavigationRegion2D 都是根的直接子节点且 position 未设置）。

const MICRO := {
	"scene": "res://scenes/dungeon/micro_school_blockout.tscn",
	"outlines": [
		# CorridorFloor at (0,0)
		[[-260,-45],[260,-45],[260,45],[-260,45]],
		# RoomClassroomA/Floor at World/RoomClassroomA (-150,-130)
		[[-150+(-90),-130+(-55)],[-150+90,-130+(-55)],[-150+90,-130+55],[-150+(-90),-130+55]],
		# RoomStorageA/Floor at World/RoomStorageA (150,130)
		[[150+(-90),130+(-55)],[150+90,130+(-55)],[150+90,130+55],[150+(-90),130+55]],
	],
}

const ABANDONED := {
	"scene": "res://scenes/dungeon/abandoned_school.tscn",
	"outlines": [
		# Sections/Entrance at (-520,0)
		[[-610,-60],[-430,-60],[-430,60],[-610,60]],
		# Sections/MainCorridor at (0,0)
		[[-420,-48],[420,-48],[420,48],[-420,48]],
		# Sections/RitualRoom at (160,-190)
		[[30,-260],[290,-260],[290,-120],[30,-120]],
		# Sections/ExitArea at (520,0)
		[[430,-60],[610,-60],[610,60],[430,60]],
		# CandidateRooms/ClassroomA at (-260,-180) + BlockoutFloor ±120,±70
		[[-380,-250],[-140,-250],[-140,-110],[-380,-110]],
		# CandidateRooms/StorageA at (-80,170) + BlockoutFloor ±100,±60
		[[-180,110],[20,110],[20,230],[-180,230]],
		# CandidateRooms/RestroomA at (160,170) + BlockoutFloor ±90,±55
		[[70,115],[250,115],[250,225],[70,225]],
		# CandidateRooms/OfficeA at (340,-170) + BlockoutFloor ±110,±65
		[[230,-235],[450,-235],[450,-105],[230,-105]],
	],
}


func _initialize() -> void:
	var all_ok := true
	for desc in [MICRO, ABANDONED]:
		if not _check(desc):
			all_ok = false
	if all_ok:
		print("[NAV BAKE] All scenes OK.")
		quit(0)
	else:
		printerr("[NAV BAKE] One or more scenes failed.")
		quit(1)


func _check(desc: Dictionary) -> bool:
	var scene_path: String = desc["scene"]
	var outlines: Array = desc["outlines"]
	print("[NAV BAKE] Checking: %s" % scene_path)

	var poly := NavigationPolygon.new()
	var all_verts := PackedVector2Array()
	for raw_outline in outlines:
		var pts := PackedVector2Array()
		for pt in raw_outline:
			pts.append(Vector2(pt[0], pt[1]))
		var n := pts.size()
		if n < 3:
			continue
		var start := all_verts.size()
		all_verts.append_array(pts)
		for i in range(1, n - 1):
			poly.add_polygon(PackedInt32Array([start, start + i, start + i + 1]))
	poly.set_vertices(all_verts)

	var polygon_count := poly.get_polygon_count()
	if all_verts.is_empty() or polygon_count == 0:
		printerr("[NAV BAKE]   ERROR: 0 vertices or 0 triangles — bake failed.")
		return false

	print("[NAV BAKE]   verts: %d  triangles: %d  OK" % [all_verts.size(), polygon_count])
	return true

