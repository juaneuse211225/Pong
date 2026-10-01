extends CanvasLayer

signal pause_selected

@onready var player1_score = $PlayerScore1
@onready var player2_score = $PlayerScore2

@onready var click_sound: AudioStreamPlayer = $ClickSound

func update_score(score1, score2):
	player1_score.text = str(score1)
	player2_score.text = str(score2)

func _on_pause_pressed() -> void:
	click_sound.play()
	await click_sound.finished
	pause_selected.emit()
