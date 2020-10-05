extends Entity
class_name Player

const _BULLET: PackedScene = preload("res://bullets/player_bullet/PlayerBullet.tscn")

export var _bullet_kickback: int

onready var _bullet_spawn : Position2D = $PlayerRig/Body/RightCannon/BulletSpawn
onready var _bullet_spawn2 : Position2D = $PlayerRig/Body/RightCannon/BulletSpawn2
onready var _animation_tree: AnimationTree = $PlayerRig/AnimationTree
onready var _animation_state: AnimationNodeStateMachinePlayback = _animation_tree.get(
	"parameters/playback"
)


func hurt(damage_taken: int) -> void:
	_health -= damage_taken
	_hit_animation_player.play("hurt")
	emit_signal("is_hit", _trauma)


func _process(_delta: float) -> void:
	_get_user_input()


func _integrate_forces(state: Physics2DDirectBodyState) -> void:
	_move(state)


func _get_user_input() -> void:
	var current_state = IDLE
	_rotation_direction = 0

	if Input.is_action_pressed("ui_up"):
		current_state = FORWARD
		_thrust = Vector2(_engine_thrust, 0)
	else:
		_thrust = Vector2.ZERO

	if Input.is_action_pressed("ui_right"):
		current_state = RIGHT
		_rotation_direction += 1
	if Input.is_action_pressed("ui_left"):
		current_state = LEFT
		_rotation_direction -= 1

	_animation_state.travel(state_strings[current_state])

	if Input.is_action_pressed("ui_select") and not _is_shooting:
		_fire()


func _fire() -> void:
	# kickback the player when firing a bullet
	apply_impulse(Vector2.ZERO, -_bullet_kickback * Vector2(cos(rotation), sin(rotation)))

	var bullet1: PlayerBullet = _BULLET.instance()
	bullet1.global_position = _bullet_spawn.global_position
	bullet1.rotation = rotation
	get_parent().add_child(bullet1)
	
	var bullet2: PlayerBullet = _BULLET.instance()
	bullet2.global_position = _bullet_spawn2.global_position
	bullet2.rotation = rotation
	get_parent().add_child(bullet2)
	
	_is_shooting = true
	_bullet_delay.start()
