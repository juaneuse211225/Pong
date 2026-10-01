extends Control

signal single_player_selected
signal two_players_selected
signal quit_selected

@onready var click_sound: AudioStreamPlayer = $ClickSound

func _on_btn_single_player_pressed() -> void:
	click_sound.play()
	await click_sound.finished
	single_player_selected.emit()

func _on_btn_two_players_pressed() -> void:
	click_sound.play()
	await click_sound.finished
	two_players_selected.emit()

func _on_btn_quit_pressed() -> void:
	click_sound.play()
	await click_sound.finished
	quit_selected.emit()
