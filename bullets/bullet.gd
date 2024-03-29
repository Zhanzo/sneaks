class_name Bullet
extends Area2D

var _speed: int = 500
var _damage: int = 1

onready var _sprite: Sprite = $Sprite
onready var _death_timer: Timer = $DeathTimer
onready var _explosion: Particles2D = $Explosion
onready var _collision_shape: CollisionShape2D = $CollisionShape2D
onready var _collision_sound: AudioStreamPlayer2D = $CollisionSound


func _physics_process(delta: float) -> void:
	position += Vector2(_speed, 0).rotated(rotation) * delta


func initialize(pos: Position2D, rot: float) -> void:
	global_position = pos.global_position
	rotation = rot


func _explode() -> void:
	_death_timer.start()
	_explosion.emitting = true
	_sprite.visible = false
	_collision_shape.set_deferred("disabled", true)
	_collision_sound.play()
	set_physics_process(false)


func _on_Bullet_body_entered(body: PhysicsBody2D) -> void:
	if body is Entity:
		body.hurt(_damage)
	_explode()


func _on_Bullet_area_entered(_area: Bullet) -> void:
	_explode()


func _on_DeathTimer_timeout() -> void:
	queue_free()


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
