extends Area2D

export var speed = 0
export var damage = 0

var velocity = Vector2.ZERO


func _process(delta):
	_move_bullet(delta)
	_remove_if_off_screen()

func _move_bullet(delta):
	velocity = Vector2(1, 0).rotated(rotation) * speed
	position += velocity * delta


func _remove_if_off_screen():
	var 	viewport_rect = get_viewport_rect()
	if position.x < viewport_rect.position.x or position.x > viewport_rect.end.x or \
	   position.y < viewport_rect.position.y or position.y > viewport_rect.end.y:
		queue_free()
