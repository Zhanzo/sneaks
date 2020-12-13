extends Node2D

export var freeze_delay: int = 15
export var player_low_health: int = 5

onready var _player: Player = $Player
onready var _camera: Camera2D = $Camera
onready var _enemies: Node2D = $Enemies
onready var _obstacles: TileMap = $ObstacleTileMap
onready var _background: Sprite = $BackgroundSprite
onready var _grayscale_filter: ColorRect = $CanvasLayer/GrayScale
onready var _low_health_audio: AudioStreamPlayer = $LowHealthAudio
onready var _muffled_bus_idx: int = AudioServer.get_bus_index("MuffledBus")

var _player_is_near_death: bool = false


func _ready() -> void:
	_grayscale_filter.material.set_shader_param("activate_grayscale", false)
	AudioServer.set_bus_effect_enabled (_muffled_bus_idx, 0, false)

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
