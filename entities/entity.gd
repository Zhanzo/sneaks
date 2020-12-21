class_name Entity
extends KinematicBody2D

export var health: int
export var damage: int
export var speed: int
export var turn_speed: float
export var trauma: float
export var fire_rate: float
export var bullet_scene: PackedScene


var _rotation_direction: float = 0.0 

onready var _attack_timer: Timer = $AttackTimer
onready var _explosion: Particles2D = $Explosion
onready var _hit_sound: AudioStreamPlayer2D = $HitSound
onready var _bullet_sound: AudioStreamPlayer2D = $BulletSound
onready var _collision_shape: CollisionShape2D = $CollisionShape2D
onready var _explosion_sound: AudioStreamPlayer2D = $ExplosionSound
onready var _hit_animation_player: AnimationPlayer= $HitAnimationPlayer


func _ready() -> void:
	_attack_timer.wait_time = fire_rate
