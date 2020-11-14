class_name Cruiser
extends Enemy


onready var _rig: Node2D = $CruiserRig
onready var _animation_tree: AnimationTree = $CruiserRig/AnimationTree
onready var _animation_state: AnimationNodeStateMachinePlayback = _animation_tree.get(
		"parameters/playback")


func _process(delta: float) -> void:	
	match _current_state:
		States.REST:
			_rest()
		States.ATTACK:
			_attack()
		States.SEARCH:
			_search(delta)


func _physics_process(delta: float) -> void:
	# no movement if the cruiser is resting
	if _current_state == States.REST:
		return
	
	_acceleration = Vector2(speed, 0).rotated(rotation)
	_acceleration -= _velocity * friction
	_velocity += _acceleration * delta
	_velocity = Vector2(speed, 0).rotated(rotation)
	_velocity = move_and_slide(_velocity)
	
	_handle_out_of_bounds()
	
	var blend_vector: Vector2 = Vector2(_rotation_direction, 1)
	blend_vector = blend_vector.normalized()
	_animation_tree.set("parameters/Forward/blend_position", blend_vector)
	_animation_state.travel("Forward")


func _rest() -> void:
	_animation_tree.set("parameters/Idle/blend_position", Vector2(0, 1))
	_animation_state.travel("Idle")


func _attack() -> void:
	_rotate_to_point(_player.global_position)

	if not _is_shooting:
		_fire_bullet()


func _search(delta: float) -> void:
	# if we do not have a navigation2d node we cannot search
	if not navigation_2d:
		_current_state = States.REST
		return
	
	var current_point: Vector2 = global_position
	var path_to_player: PoolVector2Array = navigation_2d.get_simple_path(
			current_point, _player_last_position)
	# the maximum distance the enemy can move (without friction)
	var move_distance: float = speed * delta
	
	while path_to_player.size() > 0:
		var next_point: Vector2 = path_to_player[0]
		var distance_to_next_point: float = current_point.distance_to(next_point)
		
		if move_distance <= distance_to_next_point:
			_rotate_to_point(next_point)
			break

		move_distance -= distance_to_next_point
		current_point = next_point
		path_to_player.remove(0)
	
	if path_to_player.size() <= 0:
		_current_state = States.REST


func _rotate_to_point(point: Vector2) -> void:
	var angle_to_point: float = global_position.direction_to(point).angle()
	
	# avoid rotation animations if the rotation is small
	if abs(angle_to_point - rotation) > 0.2:
		_rotation_direction = 1 if angle_to_point > rotation else -1
	else:
		_rotation_direction = 0
	
	rotation = lerp_angle(rotation, angle_to_point, turn_speed)


func _explode() -> void:
	_rig.visible = false
	._explode()
