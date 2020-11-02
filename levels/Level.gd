extends Node2D

onready var _camera := $Camera
onready var _background := $Background
onready var _player := $Player
onready var _enemies := $Enemies

func _ready() -> void:
	var level_size : Rect2 = _background.region_rect
	
	# set the camera limits
	_camera.limit_top = level_size.position.y
	_camera.limit_left = level_size.position.x
	_camera.limit_bottom = level_size.end.y
	_camera.limit_right = level_size.end.x
	
	# set the player and enemy limits
	_player.level_size = level_size
	for enemy in _enemies.get_children():
		enemy.level_size = level_size


func _on_Player_is_hit(trauma : float) -> void:
	_camera.add_trauma(trauma)


func _on_Enemy_is_hit(trauma : float) -> void:
	_camera.add_trauma(trauma)
