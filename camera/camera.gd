extends Camera2D

export var decay: float
export var max_offset: Vector2
export var max_roll: float

var _trauma: float
var _trauma_power: int = 3
var _noise_y: int = 0

onready var _noise: OpenSimplexNoise = OpenSimplexNoise.new()


func _ready() -> void:
	randomize()
	_noise.seed = randi()
	_noise.period = 4
	_noise.octaves = 2


func _process(delta: float) -> void:
	if _trauma:
		_trauma = max(_trauma - decay * delta, 0.0)
		_shake()


func set_limits(value: Rect2) -> void:
	limit_left = value.position.x
	limit_right = value.end.x
	limit_top = value.position.y
	limit_bottom = value.end.y


func add_trauma(amount: float) -> void:
	_trauma = min(_trauma + amount, 1.0)


func _shake() -> void:
	var amount: float = pow(_trauma, _trauma_power)
	_noise_y += 1
	rotation = max_roll * amount * _noise.get_noise_2d(_noise.seed, _noise_y)
	var offset_vector: Vector2 = Vector2(
		max_offset.x * amount * _noise.get_noise_2d(_noise.seed * 2, _noise_y),
		max_offset.y * amount * _noise.get_noise_2d(_noise.seed * 3, _noise_y)
	)
	get_tree().get_root().global_canvas_transform.origin = offset_vector
