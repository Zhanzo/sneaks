class_name Player
extends Entity

signal is_hit(trauma, health)
signal health_regained(health)

export var bullet_kickback: int
export var max_health: int

var _is_hit: bool = false

onready var _rig: Node2D = $PlayerRig
onready var _death_timer: Timer = $DeathTimer
onready var _hit_timer: Timer = $HitTimer
onready var _health_regen_timer: Timer = $HealthRegenTimer
onready var _bullet_spawn1: Position2D = $PlayerRig/Body/RightCannon/BulletSpawn1
onready var _bullet_spawn2: Position2D = $PlayerRig/Body/RightCannon/BulletSpawn2
onready var _exhaust1: Particles2D = $PlayerRig/Body/LeftCannon/Exhaust1
onready var _exhaust2: Particles2D = $PlayerRig/Body/LeftCannon/Exhaust2
onready var _animation_player: AnimationPlayer = $AnimationPlayer
onready var _animation_tree: AnimationTree = $PlayerRig/AnimationTree
onready var _animation_state: AnimationNodeStateMachinePlayback = _animation_tree.get(
	"parameters/playback"
)


func _ready() -> void:
	health = max_health


func _process(_delta: float) -> void:
	_get_user_input()


func _physics_process(delta: float) -> void:
	_acceleration -= _velocity * friction
	_velocity += _acceleration * delta
	rotation += turn_speed * _rotation_direction * delta
	
	_handle_out_of_bounds()
	
	_velocity = move_and_slide(_velocity)


func hurt(damage_taken: int) -> void:
	health -= damage_taken
	_hit_animation_player.play("hurt")
	emit_signal("is_hit", trauma, health)
	_hit_timer.start()
	_is_hit = true

	# If the player's health reaches zero the game is over
	if health <= 0:
		_explode()


func _get_user_input() -> void:
	_rotation_direction = (
		Input.get_action_strength("ui_right")
		- Input.get_action_strength("ui_left")
	)

	# calculate which animation to play in the animation tree
	var input_vector: Vector2 = Vector2(_rotation_direction, 1)
	input_vector = input_vector.normalized()

	if Input.is_action_pressed("ui_up"):
		_animation_tree.set("parameters/Forward/blend_position", input_vector)
		_animation_state.travel("Forward")
		_acceleration = Vector2(speed, 0).rotated(rotation)
	else:
		_animation_tree.set("parameters/Idle/blend_position", input_vector)
		_animation_state.travel("Idle")
		_acceleration = Vector2.ZERO

	# shake the player whenever it presses down since the ship cannot
	# travel backwards
	if Input.is_action_pressed("ui_down"):
		_animation_player.play("shake")

	if Input.is_action_pressed("ui_select") and not _is_shooting:
		_fire_bullet()


func _fire_bullet() -> void:
	# kickback the player when firing a bullet
	_acceleration -= Vector2(bullet_kickback, 0).rotated(rotation)

	var bullet1: Bullet = bullet_scene.instance()
	bullet1.initialize(_bullet_spawn1, rotation)
	get_parent().add_child(bullet1)

	var bullet2: Bullet = bullet_scene.instance()
	bullet2.initialize(_bullet_spawn2, rotation)
	get_parent().add_child(bullet2)

	_is_shooting = true
	_bullet_delay.start()


func _explode() -> void:
	_death_timer.start()
	_rig.visible = false
	_explosion.emitting = true
	_collision_shape.set_deferred("disabled", true)
	set_physics_process(false)
	set_process(false)


func _on_HitTimer_timeout() -> void:
	_is_hit = false
	_health_regen_timer.start()


func _on_HealthRegenTimer_timeout() -> void:
	health += 1
	emit_signal("health_regained", health)
	if health < max_health and not _is_hit:
		_health_regen_timer.start()


func _on_DeathTimer_timeout():
	if get_tree().change_scene("res://menus/game_over_menu/game_over_menu.tscn") != OK:
		print("Error occured when switching scene")
