extends "res://entities/Entity.gd"

const BULLET = preload("res://bullets/cruiser_bullet/CruiserBullet.tscn")

export (NodePath) var player_path = null
var player

onready var animation_tree = $CruiserRig/AnimationTree
onready var animation_state = animation_tree.get("parameters/playback")


func _ready():
	player = get_node(player_path)
	screen_size = get_viewport().get_visible_rect().size


func _process(_delta):
	_decide_on_actions()


func _integrate_forces(state):
	_move(state)


func _decide_on_actions():
	var current_state = FORWARD
	
	if player:
		var direction = position.direction_to(player.position)
		thrust = Vector2(engine_thrust, 0)
		
		if direction.angle() > rotation:
			current_state = LEFT
			rotation_direction = 1
		elif direction.angle() < rotation:
			current_state = RIGHT
			rotation_direction = -1
			
		if not is_shooting:
			_fire()
	
	animation_state.travel(state_strings[current_state])

func _move(state):
	set_applied_force(thrust.rotated(rotation))
	set_applied_torque(rotation_direction * spin_thrust)	
	
	handle_out_of_bounds(state)


func _fire():
	var bullet = BULLET.instance()
	bullet.global_position = $BulletSpawn.global_position
	bullet.rotation = rotation
	get_parent().add_child(bullet)
	is_shooting = true
	$BulletDelay.start()
