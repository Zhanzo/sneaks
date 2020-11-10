class_name Entity
extends RigidBody2D

export var health: int
export var damage: int
export var engine_thrust: int
export var spin_thrust: int
export var trauma: float
export var fire_rate: float

var level_size: Rect2

var _bullet_scene: PackedScene
var _thrust: Vector2 = Vector2.ZERO
var _rotation_direction: int = 0
var _is_shooting: bool = false

onready var _collision_shape: CollisionShape2D = $CollisionShape2D
onready var _hit_animation_player: AnimationPlayer = $HitAnimationPlayer
onready var _bullet_delay: Timer = $BulletDelay
onready var _explosion: Particles2D = $Explosion


func _ready() -> void:
	_bullet_delay.wait_time = fire_rate


func _integrate_forces(state: Physics2DDirectBodyState) -> void:
	_move(state)


func _move(state: Physics2DDirectBodyState) -> void:
	set_applied_force(_thrust.rotated(rotation))
	set_applied_torque(_rotation_direction * spin_thrust)

	_handle_out_of_bounds(state)


func _handle_out_of_bounds(state: Physics2DDirectBodyState) -> void:
	var xform: Transform2D = state.get_transform()
	xform.origin.x = clamp(xform.origin.x, level_size.position.x, level_size.end.x)
	xform.origin.y = clamp(xform.origin.y, level_size.position.y, level_size.end.y)
	state.set_transform(xform)


func _on_BulletDelay_timeout() -> void:
	_is_shooting = false
