extends AudioStreamPlayer


onready var _restart_timer: Timer = $RestartTimer


func _on_BackgroundMusic_finished():
	_restart_timer.start()


func _on_RestartTimer_timeout():
	play()
