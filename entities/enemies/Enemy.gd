extends Entity
class_name Enemy

signal is_hit(trauma)

export var _player_path: NodePath
var _player: Player

onready var _bullet_spawn: Position2D = $BulletSpawn

func hurt(damage_taken: int) -> void:
	_health -= damage_taken
	_hit_animation_player.play("hurt")
	emit_signal("is_hit", _trauma)
	if _health <= 0:
		queue_free()


func _ready() -> void:
	_player = get_node(_player_path)


func _fire_bullet() -> void:
	var bullet: Bullet = _bullet_scene.instance()
	bullet.global_position = _bullet_spawn.global_position
	bullet.rotation = rotation
	get_parent().add_child(bullet)
	_is_shooting = true
	_bullet_delay.start()
