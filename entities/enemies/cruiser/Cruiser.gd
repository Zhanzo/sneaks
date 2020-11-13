class_name Cruiser
extends Enemy


onready var _rig: Node2D = $CruiserRig
onready var _animation_tree: AnimationTree = $CruiserRig/AnimationTree
onready var _animation_state: AnimationNodeStateMachinePlayback = _animation_tree.get(
	"parameters/playback"
)


func _physics_process(delta: float) -> void:
	_decide_on_actions()
	
	_acceleration -= _velocity * friction
	_velocity += _acceleration * delta
	
	_handle_out_of_bounds()
	
	_velocity = move_and_slide(_velocity)


func _decide_on_actions() -> void:
	_rotation_direction = 0

	if player:
		# always move forward when player exists
		_acceleration = Vector2(speed, 0).rotated(rotation)

		var angle_to_player: float = global_position.direction_to(player.global_position).angle()
		
		if abs(angle_to_player - rotation) > 0.1:
			_rotation_direction = 1 if angle_to_player > rotation else -1

		var blend_vector: Vector2 = Vector2(_rotation_direction, 1)
		blend_vector = blend_vector.normalized()

		_animation_tree.set("parameters/Forward/blend_position", blend_vector)
		_animation_state.travel("Forward")
		
		rotation = lerp_angle(rotation, angle_to_player, turn_speed)

		if not _is_shooting and abs(rotation - angle_to_player) < 0.1:
			_fire_bullet()
	else:
		var blend_vector: Vector2 = Vector2(_rotation_direction, 1)
		_animation_tree.set("parameters/Idle/blend_position", blend_vector)
		_animation_state.travel("Idle")


func _explode() -> void:
	_rig.visible = false
	._explode()
