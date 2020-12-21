extends Control


onready var _label: Label = $VBoxContainer/Label
onready var _next_level_button: Button = $VBoxContainer/NextLevelButton

var _next_level: int


func _ready() -> void:
	visible = false


func show_menu(next_level: int) -> void:
	_next_level = next_level
	get_tree().paused = true
	visible = true


func set_label(value: String) -> void:
	_label.text = value


func set_next_level_button_visibility(value: bool) -> void:
	_next_level_button.visible = value


func _on_NextLevelButton_pressed():
	get_tree().paused = false
	var next_level_scene: String = "res://levels/Level" + str(_next_level) + ".tscn"
	if get_tree().change_scene(next_level_scene) != OK:
		if get_tree().change_scene("res://menus/level_select_menu/level_select_menu.tscn") != OK:
			print("Error occured when switching scene")


func _on_ExitButton_pressed():
	get_tree().paused = false
	if get_tree().change_scene("res://menus/main_menu/main_menu.tscn") != OK:
		print("Error occured when switching scene")
