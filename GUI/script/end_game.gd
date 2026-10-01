extends Control

signal restart_selected
signal quit_selected

@onready var click_sound: AudioStreamPlayer = $ClickSound

func _on_restart_pressed() -> void:
	click_sound.play()
	await click_sound.finished
	restart_selected.emit()

func _on_quit_pressed() -> void:
	click_sound.play()
	await click_sound.finished
	quit_selected.emit()
