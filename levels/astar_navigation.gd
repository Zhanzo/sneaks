extends TileMap

export var map_size: Vector2

var path_start_position: Vector2 setget _set_path_start_position
var path_end_position: Vector2 setget _set_path_end_position

var _point_path: Array

onready var astar_node: AStar2D = AStar2D.new()
onready var obstacles: Array = get_used_cells_by_id(0)
onready var _half_cell_size: Vector2 = cell_size / 2


func _ready() -> void:
	var walkable_cells_list = astar_add_walkable_cells(obstacles)
	astar_connect_walkable_cells(walkable_cells_list)


func astar_add_walkable_cells(obstacle_list: Array = []) -> Array:
	var points_array: Array = []
	for y in range(map_size.y):
		for x in range(map_size.x):
			var point: Vector2 = Vector2(x, y)
			if point in obstacle_list:
				continue
			points_array.append(point)
			var point_index: int = calculate_point_index(point)
			astar_node.add_point(point_index, point)
	return points_array


func astar_connect_walkable_cells(points_array: Array):
	for point in points_array:
		var point_index: int = calculate_point_index(point)
		var points_relative: PoolVector2Array = PoolVector2Array([
			point + Vector2.UP,
			point + Vector2.LEFT,
			point + Vector2.DOWN,
			point + Vector2.LEFT])
		for point_relative in points_relative:
			var point_relative_index: int = calculate_point_index(point_relative)
			if is_outside_map_boundaries(point_relative) or \
					not astar_node.has_point(point_relative_index):
				continue
			astar_node.connect_points(point_index, point_relative_index, true)


func get_astar_path(world_start: Vector2, world_end: Vector2) -> Array:
	self.path_start_position = world_to_map(world_start)
	self.path_end_position = world_to_map(world_end)
	_recalculate_path()
	var path_world: Array = []
	for point in _point_path:
		var point_world: Vector2 = map_to_world(point) + _half_cell_size
		path_world.append(point_world)
	return path_world


func calculate_point_index(point: Vector2) -> int:
	return int(point.x + point.y * map_size.x)


func is_outside_map_boundaries(point: Vector2) -> bool:
	return point.x < 0 or point.y < 0 or point.x >= map_size.x or point.y >= map_size.y


func _recalculate_path() -> void:
	var start_point_index: int = calculate_point_index(path_start_position)
	var end_point_index: int = calculate_point_index(path_end_position)
	_point_path = astar_node.get_point_path(start_point_index, end_point_index)


func _set_path_start_position(value: Vector2) -> void:
	if value in obstacles or is_outside_map_boundaries(value):
		return
	path_start_position = value
	if path_end_position and path_end_position != path_start_position:
		_recalculate_path()


func _set_path_end_position(value: Vector2) -> void:
	if value in obstacles or is_outside_map_boundaries(value):
		return
	path_end_position = value
	if path_start_position != value:
		_recalculate_path()
