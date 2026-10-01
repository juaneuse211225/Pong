extends Node2D

signal quit_to_main_menu

@onready var player1 = $Player1
@onready var player2 = $Player2
@onready var ball = $Ball

@onready var victory_music: AudioStreamPlayer = $VictoryMusic
@onready var defeat_music: AudioStreamPlayer = $DefeatMusic

@onready var hud = $HUD
@onready var end_game_n = $MenusContainer/EndGame
@onready var winner_label = $MenusContainer/EndGame/Label
@onready var title_label = $MenusContainer/EndGame/TitleLabel
@onready var final_score_label = $MenusContainer/EndGame/FinalScoreLabel
@onready var pause_menu = $MenusContainer/PauseMenu

var player1_score := 0
var player2_score := 0

var current_mode: GameMode

enum GameMode {
	ONE_PLAYER,
	TWO_PLAYERS
}

enum GameState{
	MENU,
	PLAYING,
	GAME_OVER
}

var current_state := GameState.MENU

var bgm_player: AudioStreamPlayer

func setup_audio(player: AudioStreamPlayer) -> void:
	bgm_player = player

func _ready() -> void:
	ball.goal.connect(_on_ball_goal)
	hud.update_score(player1_score, player2_score)

	hud.pause_selected.connect(_on_pause_requested)
	pause_menu.resume_selected.connect(_on_resume_requested)
	pause_menu.quit_selected.connect(_on_quit_requested)
	
	end_game_n.restart_selected.connect(_on_restart_requested)
	end_game_n.quit_selected.connect(_on_quit_requested)

func startGame(mode: GameMode):
	current_mode = mode
	
	if current_mode == GameMode.ONE_PLAYER:
		player2.is_ai = true
	else:
		player2.is_ai = false
	
	hud.visible = true
	get_tree().paused = false
	current_state = GameState.PLAYING
	
	player1.active = true
	player2.active = true
	
	end_game_n.visible = false
	pause_menu.visible = false
	
	ball.start()

func _on_ball_goal(player):
	if current_state != GameState.PLAYING:
		return
	
	if player == 1:
		player1_score += 1
	else:
		player2_score += 1
		
	hud.update_score(player1_score, player2_score)
	
	if player1_score >= 11 or player2_score >= 11:
		end_game()
	else:
		reset_round()

func end_game():
	hud.visible = false
	current_state = GameState.GAME_OVER
	ball.velocity = Vector2.ZERO
	
	player1.active = false
	player2.active = false
	
	if bgm_player:
		bgm_player.stop()
		bgm_player.stream_paused = false
	
	if player1_score > player2_score:
		winner_label.text = "PLAYER 1 WINS"
		victory_music.play()
	else:
		if player2.is_ai:
			title_label.text = "DEFEAT"
			defeat_music.play()
		else:
			winner_label.text = "PLAYER 2 WINS"
			victory_music.play()
	
	final_score_label.text = str(player1_score) + " - " + str(player2_score)
	end_game_n.visible = true
	get_tree().paused = true

func reset_round():
	player1.reset()
	player2.reset()
	ball.reset()
	ball.start()

func _unhandled_input(event: InputEvent) -> void:
	if current_state == GameState.GAME_OVER:
		if event.is_action_pressed("ui_accept"):
			restart_game()
		
	

func restart_game():
	player1_score = 0
	player2_score = 0
	
	hud.update_score(player1_score, player2_score)
	
	player1.reset()
	player2.reset()
	ball.reset()
	
	startGame(current_mode)

func _on_pause_requested() -> void:
	if current_state == GameState.PLAYING:
		get_tree().paused = true
		pause_menu.visible = true
		
		if bgm_player:
			bgm_player.stream_paused = true 

func _on_resume_requested() -> void:
	get_tree().paused = false
	pause_menu.visible = false
	
	if bgm_player:
		bgm_player.stream_paused = false

func _on_restart_requested() -> void:
	victory_music.stop()
	defeat_music.stop()
	
	if bgm_player:
		bgm_player.play()
		
	end_game_n.visible = false
	restart_game()

func _on_quit_requested() -> void:
	victory_music.stop()
	defeat_music.stop()
	
	get_tree().paused = false
	quit_to_main_menu.emit()
