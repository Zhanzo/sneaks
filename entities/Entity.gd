extends RigidBody2D
class_name Entity

export var _health: int
export var _damage: int
export var _engine_thrust: int
export var _spin_thrust: int

var _thrust: Vector2 = Vector2.ZERO
var _rotation_direction: int = 0
var _is_shooting: bool = false

var _screen_size: Vector2

enum { IDLE, FORWARD, LEFT, RIGHT }

var state_strings = {
	IDLE: "idle",
	FORWARD: "forward",
	LEFT: "left",
	RIGHT: "right",
}

onready var _hit_animation_player: AnimationPlayer = $HitAnimationPlayer
onready var _bullet_delay: Timer = $BulletDelay
onready var _bullet_spawn: Position2D = $BulletSpawn


func hurt(damage_taken: int) -> void:
	pass


func _ready() -> void:
	_screen_size = get_viewport().get_visible_rect().size


func _move(state: Physics2DDirectBodyState) -> void:
	set_applied_force(_thrust.rotated(rotation))
	set_applied_torque(_rotation_direction * _spin_thrust)

	_handle_out_of_bounds(state)


func _fire_bullet() -> void:
	pass


func _handle_out_of_bounds(state: Physics2DDirectBodyState) -> void:
	var xform: Transform2D = state.get_transform()
	if xform.origin.x > _screen_size.x:
		xform.origin.x = 0
	if xform.origin.x < 0:
		xform.origin.x = _screen_size.x
	if xform.origin.y > _screen_size.y:
		xform.origin.y = 0
	if xform.origin.y < 0:
		xform.origin.y = _screen_size.y
	state.set_transform(xform)


func _on_BulletDelay_timeout() -> void:
	_is_shooting = false
