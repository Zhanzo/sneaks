extends Enemy
class_name Cruiser


onready var _animation_tree: AnimationTree = $CruiserRig/AnimationTree
onready var _animation_state: AnimationNodeStateMachinePlayback = _animation_tree.get(
	"parameters/playback"
)


func _ready() -> void:
	_player = get_node(_player_path)
	_bullet_scene = preload("res://bullets/cruiser_bullet/CruiserBullet.tscn")


func _process(_delta: float) -> void:
	_decide_on_actions()


func _integrate_forces(state: Physics2DDirectBodyState) -> void:
	_move(state)


func _decide_on_actions() -> void:
	_rotation_direction = 0

	if _player:
		# always move forward when player exists
		_thrust = Vector2(_engine_thrust, 0)
		
		var direction: Vector2 = position.direction_to(_player.position)
		
		if direction.angle() > rotation:
			_rotation_direction += 1
		elif direction.angle() < rotation:
			_rotation_direction -= 1
		
		var blend_vector := Vector2(_rotation_direction, 1)
		blend_vector = blend_vector.normalized()
		
		_animation_tree.set("parameters/Forward/blend_position", blend_vector)
		_animation_state.travel("Forward")

		if not _is_shooting:
			_fire_bullet()
	else:
		var blend_vector := Vector2(_rotation_direction, 1)
		_animation_tree.set("parameters/Idle/blend_position", blend_vector)
		_animation_state.travel("Idle")
