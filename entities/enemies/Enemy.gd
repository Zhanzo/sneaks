class_name Enemy
extends Entity

signal is_hit(trauma)
signal is_killed

var player: Player

onready var _bullet_spawn: Position2D = $BulletSpawn
onready var _death_timer: Timer = $DeathTimer


func hurt(damage_taken: int) -> void:
	health -= damage_taken

	if health <= 0:
		emit_signal("is_killed")
		_explode()
	else:
		emit_signal("is_hit", trauma)
		_hit_animation_player.play("hurt")


func _explode() -> void:
	_death_timer.start()
	_explosion.emitting = true
	_collision_shape.set_deferred("disabled", true)
	set_physics_process(false)
	set_process(false)


func _fire_bullet() -> void:
	var bullet: Bullet = bullet_scene.instance()
	bullet.initialize(_bullet_spawn, rotation)
	get_parent().add_child(bullet)
	_is_shooting = true
	_bullet_delay.start()


func _on_DeathTimer_timeout():
	queue_free()
