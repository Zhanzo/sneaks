extends RigidBody2D
class_name Entity


export var _health: int
export var _damage: int
export var _engine_thrust: int
export var _spin_thrust: int
export var _trauma: float
export var _fire_rate: float

var _bullet_scene: PackedScene
var _thrust: Vector2 = Vector2.ZERO
var _rotation_direction: int = 0
var _is_shooting: bool = false

var level_size: Rect2

onready var _hit_animation_player: AnimationPlayer = $HitAnimationPlayer
onready var _bullet_delay: Timer = $BulletDelay


func _ready() -> void:
	_bullet_delay.wait_time = _fire_rate


func _move(state: Physics2DDirectBodyState) -> void:
	set_applied_force(_thrust.rotated(rotation))
	set_applied_torque(_rotation_direction * _spin_thrust)

	_handle_out_of_bounds(state)


func _handle_out_of_bounds(state: Physics2DDirectBodyState) -> void:
	var xform: Transform2D = state.get_transform()
	xform.origin.x = clamp(xform.origin.x, level_size.position.x, level_size.end.x)
	xform.origin.y = clamp(xform.origin.y, level_size.position.y, level_size.end.y)
	state.set_transform(xform)


func _on_BulletDelay_timeout() -> void:
	_is_shooting = false
