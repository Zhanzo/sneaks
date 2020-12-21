extends Control


func _ready() -> void:
	visible = false


func show_menu() -> void:
	get_tree().paused = true
	visible = true


func _on_RestartButton_pressed() -> void:
	print("Pressed")
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_ExitButton_pressed() -> void:
	get_tree().paused = false
	if get_tree().change_scene("res://menus/main_menu/main_menu.tscn") != OK:
		print("Error occured when switching scene")
