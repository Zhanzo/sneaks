extends Camera2D

export var _decay : float
export var _max_offset : Vector2
export var _max_roll : float

var _trauma : float
var _trauma_power : int = 3
var _noise_y : int = 0

onready var _noise : OpenSimplexNoise = OpenSimplexNoise.new()

func add_trauma(amount : float) -> void:
	_trauma = min(_trauma + amount, 1.0)


func _ready() -> void:
	randomize()
	_noise.seed = randi()
	_noise.period = 4
	_noise.octaves = 2


func _process(delta : float) -> void:
	if _trauma:
		_trauma = max(_trauma - _decay * delta, 0.0)
		_shake()


func _shake() -> void:
	var amount = pow(_trauma, _trauma_power)
	_noise_y += 1
	rotation = _max_roll * amount * _noise.get_noise_2d(_noise.seed, _noise_y)
	var offset_vector := Vector2(_max_offset.x * amount * _noise.get_noise_2d(_noise.seed * 2, _noise_y),
	_max_offset.y * amount * _noise.get_noise_2d(_noise.seed * 3, _noise_y))
	get_tree().get_root().global_canvas_transform.origin = offset_vector
