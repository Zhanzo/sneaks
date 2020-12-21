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

var navigation_2d: Navigation2D = null setget set_navigation_2d
var is_visible: bool = false

var _target: Player
var _start_position: Vector2
var _last_target_position: Vector2
var _current_state: int = States.REST

onready var _death_timer: Timer = $DeathTimer
onready var _search_delay: Timer = $SearchDelay
onready var _bullet_spawn: Position2D = $BulletSpawn


func _ready() -> void:
	_start_position = global_position


func _physics_process(delta):
	match _current_state:
		States.REST:
			pass
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


func set_navigation_2d(value: Navigation2D) -> void:
	navigation_2d = value


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

	# if we do not have a navigation 2d node, then we cannot move to the point
	if not navigation_2d:
		_current_state = States.REST
		return false
	
	var current_point: Vector2 = global_position
	#var path: Array = pathfinder.get_astar_path(current_point, point)
	var end_point: Vector2 = navigation_2d.get_closest_point(point)
	var path: PoolVector2Array = navigation_2d.get_simple_path(current_point, end_point)
	# the maximum distance the enemy can move
	var move_distance: float = speed * delta
	
	while not path.empty():
		var next_point: Vector2 = path[0]
		var distance_to_next_point: float = current_point.distance_to(next_point)
		
		if move_distance <= distance_to_next_point:
			_rotate_to_point(next_point)
			move_and_slide(Vector2(speed, 0).rotated(rotation))
			break
		
		move_distance -= distance_to_next_point
		current_point = next_point
		path.remove(0)
	
	return path.empty()


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
	get_parent().get_parent().add_child(bullet)
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


func _on_VisibilityNotifier2D_screen_entered():
	is_visible = true


func _on_VisibilityNotifier2D_screen_exited():
	is_visible = false
