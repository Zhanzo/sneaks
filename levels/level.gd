extends Node2D

export var freeze_delay: int = 15
export var player_grayscale_health: int = 10

onready var _obstacle_tilemap: TileMap = $ObstacleTileMap
onready var _background_tile_map: TileMap = $BackgroundTileMap
onready var _navigation_2d: Navigation2D = $Navigation2D
onready var _camera: Camera2D = $Camera
onready var _player: Player = $Player
onready var _enemies: Node2D = $Enemies
onready var _grayscale_filter: ColorRect = $CanvasLayer/GrayScale


func _ready() -> void:
	_grayscale_filter.material.set_shader_param("activate_grayscale", false)
	var tilemap_rect: Rect2 = _background_tile_map.get_used_rect()
	var tilemap_cell_size: Vector2 = _background_tile_map.cell_size
	var background_size: Vector2 = tilemap_rect.end * tilemap_cell_size
	#_obstacle_tilemap.map_size = background_size / _obstacle_tilemap.cell_size
	print(_obstacle_tilemap.map_size)

	# set the camera limits
	_camera.limit_top = tilemap_rect.position.y * tilemap_cell_size.y
	_camera.limit_left = tilemap_rect.position.x * tilemap_cell_size.x
	_camera.limit_bottom = tilemap_rect.end.y * tilemap_cell_size.y
	_camera.limit_right = tilemap_rect.end.x * tilemap_cell_size.x

	for enemy in _enemies.get_children():
		# connect enemy signals
		enemy.connect("is_hit", self, "_on_Enemy_is_hit")
		enemy.connect("is_killed", self, "_on_Enemy_is_killed")
		# set the navigation2d
		enemy.set_navigation_2d(_navigation_2d)
		enemy.set_navigation_tilemap(_obstacle_tilemap)


func _on_Enemy_is_hit(trauma: float) -> void:
	_camera.add_trauma(trauma)
	# freeze the frame slightly
	OS.delay_msec(freeze_delay)


func _on_Enemy_is_killed() -> void:
	# freeze the frame heavily
	OS.delay_msec(freeze_delay * 3)


func _on_Player_is_hit(trauma: float, health: int) -> void:
	_camera.add_trauma(trauma)
	if health <= player_grayscale_health:
		_grayscale_filter.material.set_shader_param("activate_grayscale", true)


func _on_Player_health_regained(health: int) -> void:
	if health > player_grayscale_health:
		_grayscale_filter.material.set_shader_param("activate_grayscale", false)
