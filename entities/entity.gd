class_name Entity
extends KinematicBody2D

export var health: int
export var damage: int
export var speed: int = 300
export var turn_speed: float = 1.5
export var friction: float = 0.65
export var trauma: float
export var fire_rate: float
export var bullet_scene: PackedScene

var _velocity: Vector2 = Vector2.ZERO
var _acceleration: Vector2 = Vector2.ZERO


var _rotation_direction: float = 0.0
var _is_shooting: bool = false 

onready var _collision_shape: CollisionShape2D = $CollisionShape2D
onready var _hit_animation_player: AnimationPlayer = $HitAnimationPlayer
onready var _bullet_delay: Timer = $BulletDelay
onready var _explosion: Particles2D = $Explosion


func _ready() -> void:
	_bullet_delay.wait_time = fire_rate


func _on_BulletDelay_timeout() -> void:
	_is_shooting = false
