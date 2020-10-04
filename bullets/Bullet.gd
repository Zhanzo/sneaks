extends Area2D
class_name Bullet

export var _speed: int
export var _damage: int

var _velocity: Vector2 = Vector2.ZERO


func _process(delta: float) -> void:
	_move(delta)


func _move(delta: float) -> void:
	_velocity = Vector2(1, 0).rotated(rotation) * _speed
	position += _velocity * delta


func _on_VisibilityNotifier2D_screen_exited() -> void:
	queue_free()
