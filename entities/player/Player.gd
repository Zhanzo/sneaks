extends "res://entities/Entity.gd"

const BULLET = preload("res://bullets/player_bullet/PlayerBullet.tscn")

export (int) var bullet_kickback = -50

onready var animation_tree = $PlayerRig/AnimationTree
onready var animation_state = animation_tree.get("parameters/playback")


func _process(_delta):
	_get_user_input()
	
func _integrate_forces(state):
	_move(state)


func _get_user_input():
	var current_state = IDLE
	rotation_direction = 0
	
	if Input.is_action_pressed("ui_up"):
		current_state = FORWARD
		thrust = Vector2(engine_thrust, 0)
	else:
		thrust = Vector2.ZERO
	
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
	# kickback the player when firing a bullet
	apply_impulse(Vector2.ZERO, bullet_kickback * Vector2(cos(rotation), sin(rotation)))
	
	var bullet = BULLET.instance()
	bullet.global_position = $BulletSpawn.global_position
	bullet.rotation = rotation
	get_parent().add_child(bullet)
	is_shooting = true
	$BulletDelay.start()


func _move(state):
	set_applied_force(thrust.rotated(rotation))
	set_applied_torque(rotation_direction * spin_thrust)
	
	handle_out_of_bounds(state)
