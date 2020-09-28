extends "res://entities/Entity.gd"

const BULLET = preload("res://bullets/player_bullet/PlayerBullet.tscn")

var is_shooting = false

onready var animation_tree = $PlayerRig/AnimationTree
onready var animation_state = animation_tree.get("parameters/playback")


func _physics_process(delta):
	_get_user_input()
	_move(delta)


func _get_user_input():
	var current_state = IDLE
	rotation_direction = 0
	velocity = Vector2.ZERO
	
	if Input.is_action_pressed("ui_up"):
		current_state = FORWARD
		velocity = Vector2(1, 0).rotated(rotation) * speed
	
	if Input.is_action_pressed("ui_right"):
		current_state = RIGHT
		rotation_direction += 1
	if Input.is_action_pressed("ui_left"):
		current_state = LEFT
		rotation_direction -= 1
	
	animation_state.travel(state_strings[current_state])
	
	if Input.is_action_pressed("ui_select") and not is_shooting:
		_fire_bullet()


func _fire_bullet():
	var bullet = BULLET.instance()
	bullet.global_position = $BulletSpawn.global_position
	bullet.rotation = rotation
	get_parent().add_child(bullet)
	is_shooting = true
	$BulletDelay.start()


func _move(delta):
	rotation += rotation_direction * rotation_speed * delta
	velocity = move_and_slide(velocity)
	
	# clamp the player within the viewport
	var 	viewport_rect = get_viewport_rect()
	position.x = clamp(position.x, viewport_rect.position.x, viewport_rect.end.x - 1)
	position.y = clamp(position.y, viewport_rect.position.y, viewport_rect.end.y - 1)


func _on_BulletDelay_timeout():
	is_shooting = false


func _on_CollisionArea_area_entered(area):
	health -= area.damage
	$HitAnimationPlayer.play("hurt")
	area.queue_free()
