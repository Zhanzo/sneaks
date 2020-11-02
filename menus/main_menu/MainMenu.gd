extends MarginContainer


func _on_PlayButton_pressed() -> void:
	if get_tree().change_scene("res://levels/Level.tscn") != OK:
		print("Error occured when switching scene")

func _on_ExitButton_pressed() -> void:
	get_tree().quit()
