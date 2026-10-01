extends Node

enum GameMode {
	ONE_PLAYER,
	TWO_PLAYERS
}

@onready var scene_container: Node = $SceneContainer
@onready var bgm_player: AudioStreamPlayer = $BGMPlayer

var game_mode: GameMode
var current_scene:Node

func _ready() -> void:
	show_main_menu()

func show_main_menu():
	if not bgm_player.playing:
		bgm_player.play()
	
	load_scene("res://GUI/main_menu.tscn")
	
	var menu = current_scene
	
	menu.single_player_selected.connect(start_game.bind(GameMode.ONE_PLAYER))
	menu.two_players_selected.connect(start_game.bind(GameMode.TWO_PLAYERS))
	menu.quit_selected.connect(get_tree().quit)

func start_game(mode: GameMode) -> void:
	load_scene("res://GUI/game.tscn")
	
	var game = current_scene
	
	if game.has_method("setup_audio"):
		game.setup_audio(bgm_player)
	
	game.quit_to_main_menu.connect(show_main_menu)
	game.startGame(mode)

func load_scene(scene_path: String) -> void:
	if current_scene:
		current_scene.queue_free()
	
	var scene = load(scene_path)
	current_scene = scene.instantiate()
	
	scene_container.add_child(current_scene)
