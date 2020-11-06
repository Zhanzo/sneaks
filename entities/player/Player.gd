extends Entity
class_name Player


signal is_hit(trauma, health)
signal health_regained(health)

const _BULLET: PackedScene = preload("res://bullets/player_bullet/PlayerBullet.tscn")

export var _bullet_kickback: int
export var _max_health: int

var is_hit := false

onready var _death_timer := $DeathTimer
onready var _hit_timer := $HitTimer
onready var _health_regen_timer := $HealthRegenTimer
onready var _bullet_spawn1: Position2D = $PlayerRig/Body/RightCannon/BulletSpawn1
onready var _bullet_spawn2: Position2D = $PlayerRig/Body/RightCannon/BulletSpawn2
onready var _exhaust1: Particles2D = $PlayerRig/Body/LeftCannon/Exhaust1
onready var _exhaust2: Particles2D = $PlayerRig/Body/LeftCannon/Exhaust2
onready var _animation_tree: AnimationTree = $PlayerRig/AnimationTree
onready var _animation_state: AnimationNodeStateMachinePlayback = _animation_tree.get(
	"parameters/playback"
)


func hurt(damage_taken: int) -> void:
	_health -= damage_taken
	_hit_animation_player.play("hurt")
	emit_signal("is_hit", _trauma, _health)
	_hit_timer.start()
	is_hit = true
	
	# If the player's health reaches zero the game is over
	if _health <= 0:
		_explode()


func _ready() -> void:
	_health = _max_health
	_bullet_scene = preload("res://bullets/player_bullet/PlayerBullet.tscn")


func _process(_delta: float) -> void:
	_get_user_input()


func _get_user_input() -> void:
	_rotation_direction =  Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	
	# calculate which animation to play in the animation tree
	var input_vector := Vector2(_rotation_direction, 1)
	input_vector = input_vector.normalized()
	
	if Input.is_action_pressed("ui_up"):
		_animation_tree.set("parameters/Forward/blend_position", input_vector)
		_animation_state.travel("Forward")
		_thrust = Vector2(_engine_thrust, 0)
	else:
		_animation_tree.set("parameters/Idle/blend_position", input_vector)
		_animation_state.travel("Idle")
		_thrust = Vector2.ZERO

	if Input.is_action_pressed("ui_select") and not _is_shooting:
		_fire_bullet()


func _fire_bullet() -> void:
	# kickback the player when firing a bullet
	apply_impulse(Vector2.ZERO, -_bullet_kickback * Vector2(cos(rotation), sin(rotation)))

	var bullet1: PlayerBullet = _bullet_scene.instance()
	bullet1.global_position = _bullet_spawn1.global_position
	bullet1.rotation = rotation
	get_parent().add_child(bullet1)
	
	var bullet2: PlayerBullet = _bullet_scene.instance()
	bullet2.global_position = _bullet_spawn2.global_position
	bullet2.rotation = rotation
	get_parent().add_child(bullet2)
	
	_is_shooting = true
	_bullet_delay.start()


func _explode() -> void:
	_death_timer.start()
	_explosion.emitting = true
	_collision_shape.set_deferred("disabled", true)
	set_physics_process(false)
	set_process(false)
	sleeping = true


func _on_HitTimer_timeout() -> void:
	is_hit = false
	_health_regen_timer.start()


func _on_HealthRegenTimer_timeout() -> void:
	_health += 1
	emit_signal("health_regained", _health)
	if _health < _max_health and not is_hit:
		_health_regen_timer.start()


func _on_DeathTimer_timeout():
	if get_tree().change_scene("res://menus/game_over_menu/GameOverMenu.tscn") != OK:
			print("Error occured when switching scene")
