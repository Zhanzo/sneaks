class_name Enemy
extends Entity

signal is_hit(trauma)
signal is_killed

enum States {
	REST,
	ATTACK,
	SEARCH,
	RETURN,
}

var astar: TileMap = null setget set_astar

var _target: Player
var _start_position: Vector2
var _last_target_position: Vector2
var _current_state: int = States.REST

onready var _death_timer: Timer = $DeathTimer
onready var _search_delay: Timer = $SearchDelay
onready var _bullet_spawn: Position2D = $BulletSpawn
onready var _pathfinding_raycast: RayCast2D = $PathfindingRaycast


func _ready() -> void:
	_start_position = global_position


func _process(delta: float) -> void:
	match _current_state:
		States.REST:
			_rest()
		States.ATTACK:
			_attack(delta)
		States.SEARCH:
			_search(delta)
		States.RETURN:
			_reaturn_to_start_position(delta)


func hurt(damage_taken: int) -> void:
	health -= damage_taken
	_hit_sound.play()

	if health <= 0:
		emit_signal("is_killed")
		_explode()
	else:
		emit_signal("is_hit", trauma)
		_hit_animation_player.play("hurt")


func set_astar(value: TileMap) -> void:
	astar = value


func _rest() -> void:
	# TODO: Allow the enemy to patrol
	pass


func _attack(delta: float) -> void:
	if _target:
		_go_to_point(_target.global_position, delta)
		_fire_bullet()
	else:
		_current_state = States.RETURN


func _search(delta: float) -> void:
	if _go_to_point(_last_target_position, delta):
		_search_delay.start()
		_current_state = States.REST


func _reaturn_to_start_position(delta: float) -> void:
	if _go_to_point(_start_position, delta):
		_current_state = States.REST


func _go_to_point(point: Vector2, delta: float) -> bool:
	# Tries to move the enemy to a given point.
	# Return true if the operation succeeded and false otherwise.
	_rotate_to_point(point)

	if not _pathfinding_raycast.is_colliding():
		return position.distance_to(point) <= 1

	# if we do not have an astar node we cannot move to the point
	if not astar:
		_current_state = States.REST
		return false
	
	var current_point: Vector2 = global_position
	var path: Array = astar.get_astar_path(current_point, point)
	#var nav_point = navigation_2d.get_closest_point(point)
	#var path_to_point: PoolVector2Array = navigation_2d.get_simple_path(current_point, nav_point)
	# the maximum distance the enemy can move (without friction)
	var move_distance: float = _velocity.length() * delta
	path.remove(0)
	
	while path.size() > 1 :
		var next_point: Vector2 = path[0]
		var distance_to_next_point: float = current_point.distance_to(next_point)
		
		if move_distance <= distance_to_next_point:
			_rotate_to_point(next_point)
			break
		
		move_distance -= distance_to_next_point
		current_point = next_point
		path.remove(0)
	
	return path.size() <= 1


func _move(delta: float) -> void:
	_acceleration = Vector2(speed, 0).rotated(rotation)
	_acceleration -= _velocity * friction
	_velocity += _acceleration * delta
	_velocity = Vector2(speed, 0).rotated(rotation)
	_velocity = move_and_slide(_velocity)


func _explode() -> void:
	_explosion_sound.play()
	_death_timer.start()
	_explosion.emitting = true
	_collision_shape.set_deferred("disabled", true)
	set_physics_process(false)
	set_process(false)


func _fire_bullet() -> void:
	var bullet: Bullet = bullet_scene.instance()
	bullet.initialize(_bullet_spawn, rotation)
	get_parent().add_child(bullet)
	_bullet_sound.play()
	_attack_timer.start()


func _rotate_to_point(point: Vector2) -> void:
	var angle_to_point: float = global_position.direction_to(point).angle()
	
	# avoid rotation animations if the rotation is small
	if abs(angle_to_point - rotation) > 0.2:
		_rotation_direction = 1 if angle_to_point > rotation else -1
	else:
		_rotation_direction = 0
	
	rotation = lerp_angle(rotation, angle_to_point, turn_speed)


func _on_DeathTimer_timeout():
	queue_free()


func _on_PlayerDetectionArea_body_entered(target: Player) -> void:
	_target = target
	_current_state = States.ATTACK


func _on_PlayerDetectionArea_body_exited(target: Player) -> void:
	_target = null
	_last_target_position = target.global_position
	_current_state = States.SEARCH


func _on_SearchDelay_timeout():
	if _current_state == States.REST:
		_current_state = States.RETURN
