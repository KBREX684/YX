extends RefCounted
class_name RoomPool
## RoomPool —— 手工候选房间池抽取器。
##
## P1 阶段只做确定性候选房间抽取，不生成大地图和连通走廊。


func draw_room_ids(
	candidate_ids: PackedStringArray,
	min_count: int,
	max_count: int,
	seed: int
) -> PackedStringArray:
	if candidate_ids.is_empty():
		return PackedStringArray()

	var lower := clampi(min_count, 0, candidate_ids.size())
	var upper := clampi(max_count, lower, candidate_ids.size())
	var rng := RandomNumberGenerator.new()
	rng.seed = seed

	var shuffled: Array[String] = []
	for id in candidate_ids:
		shuffled.append(id)
	for i in range(shuffled.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var tmp := shuffled[i]
		shuffled[i] = shuffled[j]
		shuffled[j] = tmp

	var draw_count := rng.randi_range(lower, upper)
	var result := PackedStringArray()
	for i in draw_count:
		result.append(shuffled[i])
	return result
