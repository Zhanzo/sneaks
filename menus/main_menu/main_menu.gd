extends Control

onready var _muffled_bus_idx: int = AudioServer.get_bus_index("MuffledBus")


func _ready() -> void:
	AudioServer.set_bus_effect_enabled (_muffled_bus_idx, 0, false)


func _on_PlayButton_pressed() -> void:
	if get_tree().change_scene("res://menus/level_select_menu/level_select_menu.tscn") != OK:
		print("Error occured when switching scene")


func _on_ExitButton_pressed() -> void:
	get_tree().quit()
