extends Node2D

onready var camera : Camera2D = $Camera


func _on_Player_is_hit(trauma : float) -> void:
	camera.add_trauma(trauma)


func _on_Enemy_is_hit(trauma : float) -> void:
	camera.add_trauma(trauma)
