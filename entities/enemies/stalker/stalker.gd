class_name Stalker
extends Enemy

enum SneakStates {
	HIDDEN,
	VISIBLE,
}

var _current_sneak_state: int = SneakStates.HIDDEN

onready var _rig: Node2D = $StalkerRig
onready var _animation_tree: AnimationTree = $StalkerRig/AnimationTree
onready var _muzzle_animation_player: AnimationPlayer = $StalkerRig/MuzzleAnimationPlayer
onready var _animation_state: AnimationNodeStateMachinePlayback = _animation_tree.get(
		"parameters/playback")


func _process(_delta: float) -> void:
	_play_animation()
	
	if _current_sneak_state == SneakStates.HIDDEN:
		modulate.a = 0.5
	elif _current_sneak_state == SneakStates.VISIBLE:
		modulate.a = 1.0


func _physics_process(delta: float) -> void:
	# no movement if the stalker is resting
	if _current_state == States.REST:
		return
	
	_move(delta)


func hurt(damage_taken: int) -> void:
	health -= damage_taken

	if health <= 0:
		emit_signal("is_killed")
		_explode()
	else:
		emit_signal("is_hit", trauma)
		if _current_sneak_state == SneakStates.HIDDEN:
			_hit_animation_player.play("hurt_hidden")
		elif _current_sneak_state == SneakStates.VISIBLE:
			_hit_animation_player.play("hurt_visible")


func _fire_bullet() -> void:
	if _attack_timer.is_stopped():
		print("Show muzzle")
		_muzzle_animation_player.play("flash")
		print("Muzzle shown")
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
