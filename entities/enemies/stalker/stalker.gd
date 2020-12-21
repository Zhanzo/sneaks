class_name Stalker
extends Enemy


var _is_hidden: bool = true setget set_is_hidden

onready var _rig: Node2D = $StalkerRig
onready var _raycast: RayCast2D = $RayCast2D
onready var _animation_tree: AnimationTree = $StalkerRig/AnimationTree
onready var _muzzle_animation_player: AnimationPlayer = $StalkerRig/MuzzleAnimationPlayer
onready var _animation_state: AnimationNodeStateMachinePlayback = _animation_tree.get(
		"parameters/playback")


func _process(_delta: float) -> void:
	_play_animation()


func set_is_hidden(value: bool) -> void:
	if value:
		modulate = Color(0, 0, 0, 1)
	else:
		modulate = Color(1, 1, 1, 1)
	_is_hidden = value


func hurt(damage_taken: int) -> void:
	health -= damage_taken

	if health <= 0:
		set_is_hidden(false)
		emit_signal("is_killed")
		_explode()
	else:
		emit_signal("is_hit", trauma)
		if _is_hidden:
			_hit_animation_player.play("hurt_hidden")
		else:
			_hit_animation_player.play("hurt_visible")


func _attack(delta: float) -> void:
	if _is_hidden and _raycast.get_collider() is Player:
		# Stay in position when hidden
		if _target:
			_rotate_to_point(_target.position)
			_fire_bullet()
		else:
			_current_state = States.REST
	else:
		._attack(delta)


func _fire_bullet() -> void:
	if _attack_timer.is_stopped():
		_muzzle_animation_player.play("flash")
		._fire_bullet()


func _play_animation() -> void:
	if _current_state == States.REST:
		_animation_tree.set("parameters/Idle/blend_position", Vector2(0, 1))
		_animation_state.travel("Idle")
	else:
		var blend_vector: Vector2 = Vector2(_rotation_direction, 1)
		blend_vector = blend_vector.normalized()
		_animation_tree.set("parameters/Forward/blend_position", blend_vector)
		_animation_state.travel("Forward")


func _explode() -> void:
	_rig.visible = false
	._explode()
