extends Entity
class_name Cruiser

const _BULLET: PackedScene = preload("res://bullets/cruiser_bullet/CruiserBullet.tscn")

export var _player_path: NodePath
var _player: Player

onready var _animation_tree: AnimationTree = $CruiserRig/AnimationTree
onready var _animation_state: AnimationNodeStateMachinePlayback = _animation_tree.get(
	"parameters/playback"
)


func hurt(damage_taken: int) -> void:
	_health -= damage_taken
	_hit_animation_player.play("hurt")
	emit_signal("is_hit", _trauma)
	if _health <= 0:
		queue_free()


func _ready() -> void:
	_player = get_node(_player_path)
	_screen_size = get_viewport().get_visible_rect().size


func _process(_delta: float) -> void:
	_decide_on_actions()


func _integrate_forces(state: Physics2DDirectBodyState) -> void:
	_move(state)


func _decide_on_actions() -> void:
	var current_state = FORWARD

	if _player:
		var direction: Vector2 = position.direction_to(_player.position)
		_thrust = Vector2(_engine_thrust, 0)

		if direction.angle() > rotation:
			current_state = LEFT
			_rotation_direction = 1
		elif direction.angle() < rotation:
			current_state = RIGHT
			_rotation_direction = -1

		if not _is_shooting:
			_fire()

	_animation_state.travel(state_strings[current_state])


func _fire() -> void:
	var bullet: CruiserBullet = _BULLET.instance()
	bullet.global_position = _bullet_spawn.global_position
	bullet.rotation = rotation
	get_parent().add_child(bullet)
	_is_shooting = true
	_bullet_delay.start()
