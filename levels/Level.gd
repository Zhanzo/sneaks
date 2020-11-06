extends Node2D

export var _freeze_delay : int = 15
export var _player_grayscale_health : int = 10

onready var _camera := $Camera
onready var _background := $Background
onready var _player := $Player
onready var _enemies := $Enemies
onready var _grayscale_filter := $HUD/CanvasLayer/GrayScale


func _ready() -> void:
	_grayscale_filter.material.set_shader_param("activate_grayscale", false)
	var level_size : Rect2 = _background.region_rect
	
	# set the camera limits
	_camera.limit_top = level_size.position.y
	_camera.limit_left = level_size.position.x
	_camera.limit_bottom = level_size.end.y
	_camera.limit_right = level_size.end.x
	
	# set the player limits
	_player.level_size = level_size
	
	for enemy in _enemies.get_children():
		# set enemy limits
		enemy.level_size = level_size
		# connect enemy signals
		enemy.connect("is_hit", self, "_on_Enemy_is_hit")
		enemy.connect("is_killed", self, "_on_Enemy_is_killed")


func _on_Enemy_is_hit(trauma: float) -> void:
	_camera.add_trauma(trauma)
	# freeze the frame slightly
	OS.delay_msec(_freeze_delay)


func _on_Enemy_is_killed() -> void:
	# freeze the frame heavily
	OS.delay_msec(_freeze_delay * 3)


func _on_Player_is_hit(trauma: float, health: int) -> void:
	_camera.add_trauma(trauma)
	if health <= _player_grayscale_health:
		_grayscale_filter.material.set_shader_param("activate_grayscale", true)


func _on_Player_health_regained(health: int) -> void:
	if health > _player_grayscale_health:
		_grayscale_filter.material.set_shader_param("activate_grayscale", false)
