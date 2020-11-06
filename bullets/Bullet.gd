extends Area2D
class_name Bullet

export var _speed: int
export var _damage: int

var _velocity: Vector2 = Vector2.ZERO

onready var death_timer: Timer = $DeathTimer
onready var explosion: Particles2D = $Explosion
onready var collision_shape: CollisionShape2D = $CollisionShape2D
onready var sprite: Sprite = $Sprite


func _physics_process(delta: float) -> void:
	_move(delta)


func _move(delta: float) -> void:
	_velocity = Vector2(1, 0).rotated(rotation) * _speed
	position += _velocity * delta


func _explode() -> void:
	death_timer.start()
	explosion.emitting = true
	sprite.visible = false
	collision_shape.set_deferred("disabled", true)
	set_physics_process(false)


func _on_VisibilityNotifier2D_screen_exited() -> void:
	queue_free()


func _on_Bullet_body_entered(body : Entity) -> void:
	body.hurt(_damage)
	_explode()


func _on_Bullet_area_entered(_area : Bullet) -> void:
	_explode()


func _on_DeathTimer_timeout() -> void:
	queue_free()
