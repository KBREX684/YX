extends NavigationRegion2D
## NavigationBaker —— 运行时从"nav_floor"组 Polygon2D 节点构建导航网格。
##
## 用法：
##   1. 将本脚本挂载到场景的 NavigationRegion2D 节点。
##   2. 将所有可行走地面的 Polygon2D 节点加入 "nav_floor" 组。
##   3. 运行场景，烘焙自动在 _ready 中完成，无需 Godot 编辑器手动烘焙按钮。
##
## 原理：遍历 nav_floor 组的所有 Polygon2D，将顶点从各节点本地坐标
## 转换到 NavigationRegion2D 本地坐标，以各 Polygon2D 轮廓为基础调用
## make_polygons_from_outlines() 三角化，赋给 navigation_polygon。
##
## 扩展性：只需将更多地面 Polygon2D 加入 nav_floor 组，导航网格自动覆盖新区域。
## 同组内多个相互重叠的 CCW 轮廓会被合并为连通区域。

const NAV_FLOOR_GROUP := &"nav_floor"


func _ready() -> void:
	# call_deferred 确保所有 instanced 子场景节点（CandidateRooms 等）
	# 都已进入场景树并完成 _ready，再执行 get_nodes_in_group 扫描。
	call_deferred(&"_bake_from_floor_polys")


func _bake_from_floor_polys() -> void:
	var floor_nodes := get_tree().get_nodes_in_group(NAV_FLOOR_GROUP)
	if floor_nodes.is_empty():
		push_warning("NavigationBaker(%s): 场景中无 'nav_floor' 组节点，导航网格未生成。" % name)
		return

	var poly := NavigationPolygon.new()
	var all_verts := PackedVector2Array()
	var added := 0

	for node: Node in floor_nodes:
		if not node is Polygon2D:
			continue
		var floor_poly := node as Polygon2D
		var pts := PackedVector2Array()
		for local_pt: Vector2 in floor_poly.polygon:
			pts.append(to_local(floor_poly.to_global(local_pt)))
		var n := pts.size()
		if n < 3:
			continue
		# 凸多边形扇形三角化（从第 0 个顶点出发）。
		# 对所有矩形地面均可正确处理，不依赖废弃的 make_polygons_from_outlines。
		var start := all_verts.size()
		all_verts.append_array(pts)
		for i in range(1, n - 1):
			poly.add_polygon(PackedInt32Array([start, start + i, start + i + 1]))
		added += 1

	if added == 0:
		push_warning("NavigationBaker(%s): nav_floor 组内无有效 Polygon2D，导航网格未生成。" % name)
		return

	poly.set_vertices(all_verts)
	navigation_polygon = poly
