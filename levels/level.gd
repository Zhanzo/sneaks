extends Node2D

export var freeze_delay: int = 15
export var player_grayscale_health: int = 10

onready var _obstacles: TileMap = $ObstacleTileMap
onready var _background: Sprite = $BackgroundSprite
onready var _camera: Camera2D = $Camera
onready var _player: Player = $Player
onready var _enemies: Node2D = $Enemies
onready var _grayscale_filter: ColorRect = $CanvasLayer/GrayScale


func _ready() -> void:
	_grayscale_filter.material.set_shader_param("activate_grayscale", false)

	# set the camera limits
	_camera.set_limits(_background.region_rect)

	for enemy in _enemies.get_children():
		# connect enemy signals
		enemy.connect("is_hit", self, "_on_Enemy_is_hit")
		enemy.connect("is_killed", self, "_on_Enemy_is_killed")
		# set the astar
		enemy.set_astar(_obstacles)


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
