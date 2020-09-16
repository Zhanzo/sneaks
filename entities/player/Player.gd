extends "res://entities/Entity.gd"
class_name Entity

func _ready():
	$AnimationPlayer.play("idle")

func _physics_process(delta):
	_get_user_input()
	_move(delta)
	_play_animations()

func _get_user_input():
	rotation_direction = 0
	velocity = Vector2.ZERO
	
	if Input.is_action_pressed("ui_right"):
		rotation_direction += 1
	if Input.is_action_pressed("ui_left"):
		rotation_direction -= 1
	if Input.is_action_pressed("ui_down"):
		velocity -= transform.x * speed
	if Input.is_action_pressed("ui_up"):
		velocity += transform.x * speed

func _move(delta):
	rotation += rotation_direction * rotation_speed * delta
	velocity = move_and_slide(velocity)
	
	# clamp the player within the viewport
	var 	viewport_rect = get_viewport_rect()
	position.x = clamp(position.x, viewport_rect.position.x, viewport_rect.end.x - 1)
	position.y = clamp(position.y, viewport_rect.position.y, viewport_rect.end.y - 1)

func _play_animations():
	if rotation_direction == 0:
		$AnimationPlayer.play("idle")
	elif rotation_direction < 0 and $AnimationPlayer.get_assigned_animation() != "turn_left":
		$AnimationPlayer.play("turn_left")
	elif rotation_direction > 0 and $AnimationPlayer.get_assigned_animation() != "turn_right":
		$AnimationPlayer.play("turn_right")
