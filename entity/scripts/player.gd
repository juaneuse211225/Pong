extends CharacterBody2D

@export var speed:float = 300.0
@export var player:int = 1; 
@export var height:float = 100.0
@export var is_ai:= false 
@export var ai_error = 500.0

@onready var ball = get_parent().get_node("Ball")

var ai_target_y := 0.0
var last_ball_direction:= 0.0
var last_ball_velocity_y := 0.0

var start_position: Vector2
var active:= true
var startX:float

func _ready():
	startX =global_position.x
	start_position = global_position

	if is_ai:
		ball.wall_bounced.connect(_on_ball_wall_bounced)

func _physics_process(delta: float) -> void:
	if not active:
		return;
	
	if is_ai:
		update_ai()
	else:
		update_human()
	

func update_human():
	var direction:= Vector2.ZERO
	
	if player == 1:
		direction.y = Input.get_axis("player2_up", "player2_down")
	else:
		direction.y = Input.get_axis("player1_up", "player1_down")
	
	velocity = Vector2(0, direction.y * speed)
	
	move_and_slide()


func update_ai():
	if ball.velocity.x > 0:
		if last_ball_direction <= 0:
			calculate_ai_target()

			last_ball_direction = 1
	else:
		last_ball_direction = -1
		ai_target_y = get_viewport_rect().size.y / 2.0
		
	
	var difference := ai_target_y - global_position.y
	
	if abs(difference) > 10:
		velocity.y = sign(difference) * speed
	else: 
		velocity.y = 0
	
	velocity.x = 0
	move_and_slide()

func _on_ball_wall_bounced():
	if is_ai and ball.velocity.x > 0:
		calculate_ai_target()


func calculate_ai_target():
	ai_target_y = predict_ball_y() + randf_range(-ai_error, ai_error)

func predict_ball_y() -> float:
	var time: float = (global_position.x - ball.global_position.x) / ball.velocity.x
	var predicted_y: float = ball.global_position.y + ball.velocity.y * time
	var height := get_viewport_rect().size.y
	predicted_y = fmod(predicted_y, height * 2.0)
	
	if predicted_y < 0:
		predicted_y += height * 2.0
	
	if predicted_y > height:
		predicted_y = height * 2.0 - predicted_y
	
	return predicted_y

func reset():
	global_position = start_position
	velocity = Vector2.ZERO
