extends Level

func _ready() -> void:
	_level_complete.set_label("Game Finished!")
	_level_complete.set_next_level_button_visibility(false)
