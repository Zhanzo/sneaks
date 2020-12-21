extends Control


onready var _button_row: HBoxContainer = $VBoxContainer/ButtonRow
onready var _button_row2: HBoxContainer = $VBoxContainer/ButtonRow2


func _ready() -> void:
	SaveData.load_game()
	
	for level_key in SaveData.levels.keys():
		var button_index: int = int(level_key)
		if button_index <= 2:
			_button_row.get_child(button_index).disabled = SaveData.levels[level_key]
		elif button_index <= 5:
			_button_row2.get_child(button_index % 3).disabled = SaveData.levels[level_key]


func _on_Level1Button_pressed():
	if get_tree().change_scene("res://levels/level1.tscn") != OK:
		print("Error occured when switching scene")


func _on_Level2Button_pressed():
	if get_tree().change_scene("res://levels/level2.tscn") != OK:
		print("Error occured when switching scene")


func _on_Level3Button_pressed():
	if get_tree().change_scene("res://levels/level3.tscn") != OK:
		print("Error occured when switching scene")


func _on_Level4Button_pressed():
	pass # Replace with function body.


func _on_Level5Button_pressed():
	pass # Replace with function body.


func _on_Level6Button_pressed():
	pass # Replace with function body.
