extends Node2D

export var level_id: String
export var freeze_delay: int = 15
export var player_low_health: int = 5

onready var _arrow: Sprite = $Arrow
onready var _player: Player = $Player
onready var _enemies: Node2D = $Enemies
onready var _camera: Camera2D = $Camera
onready var _background: Sprite = $BackgroundSprite
onready var _navigation_2d: Navigation2D = $Navigation2D
onready var _game_over: Control = $GameOverLayer/GameOver
onready var _low_health_audio: AudioStreamPlayer = $LowHealthAudio
onready var _grayscale_filter: ColorRect = $GrayScaleLayer/GrayScale
onready var _level_complete: Control = $LevelCompleteLayer/LevelComplete
onready var _muffled_bus_idx: int = AudioServer.get_bus_index("MuffledBus")

var _player_is_near_death: bool = false


func _ready() -> void:
	_grayscale_filter.material.set_shader_param("activate_grayscale", false)
	AudioServer.set_bus_effect_enabled (_muffled_bus_idx, 0, false)

	# set the camera limits
	_camera.set_limits(_background.region_rect)

	print(_enemies.get_child_count())
	for enemy in _enemies.get_children():
		# connect enemy signals
		enemy.connect("is_hit", self, "_on_Enemy_is_hit")
		enemy.connect("is_killed", self, "_on_Enemy_is_killed")
		# set the pathfinder
		enemy.set_navigation_2d(_navigation_2d)


func _process(_delta: float) -> void:
	_check_if_level_finished()
	_find_closest_enemy()
	_try_to_show_stalkers()


func _find_closest_enemy() -> void:
	var closest_enemy: Enemy
	var distance_to_closest_enemy: float = INF
	for enemy in _enemies.get_children():
		if enemy.is_visible:
			closest_enemy = null
			break
		elif _player.position.distance_to(enemy.position) <= distance_to_closest_enemy:
			closest_enemy = enemy
			distance_to_closest_enemy = _player.position.distance_to(enemy.position)
	if closest_enemy:
		# set a margin so the arrow is visible
		var margin: Vector2 = Vector2(20, 20)
		# find the min and max positions of the camera
		var ctrans: Transform2D = get_canvas_transform()
		var min_pos: Vector2 = -ctrans.get_origin() / ctrans.get_scale()
		var view_size: Vector2 = get_viewport_rect().size / ctrans.get_scale()
		var max_pos: Vector2 = min_pos + view_size
		_arrow.position.x = clamp(closest_enemy.position.x, min_pos.x + margin.x, max_pos.x - margin.x)
		_arrow.position.y = clamp(closest_enemy.position.y, min_pos.y + margin.y, max_pos.y - margin.y)
		_arrow.rotation = _player.position.direction_to(closest_enemy.position).angle() + PI/2
		_arrow.visible = true
	else:
		_arrow.visible = false


func _try_to_show_stalkers() -> void:
	# shows the stalkers if all cruisers are defeated
	var has_only_stalkers: bool = true
	for enemy in _enemies.get_children():
		if enemy is Cruiser:
			has_only_stalkers = false
			break
	if has_only_stalkers:
		for enemy in _enemies.get_children():
			enemy.set_is_hidden(false)


func _check_if_level_finished() -> void:
	if _enemies.get_child_count() > 0:
		return
	SaveData.levels[level_id] = false
	SaveData.save_game()
	AudioServer.set_bus_effect_enabled (_muffled_bus_idx, 0, false)
	_level_complete.show_menu(int(name) + 1)


func _on_Enemy_is_hit(trauma: float) -> void:
	_camera.add_trauma(trauma)
	# freeze the frame slightly
	OS.delay_msec(freeze_delay)


func _on_Enemy_is_killed() -> void:
	# freeze the frame heavily	
	OS.delay_msec(freeze_delay * 3)


func _on_Player_is_hit(trauma: float, health: int) -> void:
	_camera.add_trauma(trauma)
	if health <= player_low_health and not _player_is_near_death:
		_low_health_audio.play()
		_grayscale_filter.material.set_shader_param("activate_grayscale", true)
		Engine.time_scale = 0.5
		AudioServer.set_bus_effect_enabled (_muffled_bus_idx, 0, true)
		_player_is_near_death = true


func _on_Player_health_regained(health: int) -> void:
	if health > player_low_health and _player_is_near_death:
		_grayscale_filter.material.set_shader_param("activate_grayscale", false)
		Engine.time_scale = 1
		AudioServer.set_bus_effect_enabled (_muffled_bus_idx, 0, false)
		_player_is_near_death = false


func _on_Player_has_died():
	Engine.time_scale = 1
	AudioServer.set_bus_effect_enabled (_muffled_bus_idx, 0, false)
	_game_over.show_menu()
