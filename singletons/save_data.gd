extends Node

const FILE_NAME: String = "res://game-data.json"

var levels: Dictionary = {
	"1": true,
	"2": true,
	"3": true,
	"4": true,
	"5": true,
	"6": true
}


func save_game() -> void:
	var file: File = File.new()
	file.open(FILE_NAME, File.WRITE)
	file.store_string(to_json(levels))
	file.close()


func load_game() -> void:
	var file: File = File.new()
	if file.file_exists(FILE_NAME):
		file.open(FILE_NAME, File.READ)
		var data: Dictionary = parse_json(file.get_as_text())
		file.close()
		if typeof(data) == TYPE_DICTIONARY:
			levels = data
		else:
			printerr("Save data corrupted!")
