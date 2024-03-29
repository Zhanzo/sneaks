class_name Cruiser
extends Enemy


onready var _rig: Node2D = $CruiserRig
onready var _animation_tree: AnimationTree = $CruiserRig/AnimationTree
onready var _muzzle_animation_player: AnimationPlayer = $CruiserRig/MuzzleAnimationPlayer
onready var _animation_state: AnimationNodeStateMachinePlayback = _animation_tree.get(
		"parameters/playback")


func _process(_delta: float) -> void:
	_play_animation()


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
