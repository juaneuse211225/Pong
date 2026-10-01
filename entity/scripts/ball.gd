extends CharacterBody2D

signal goal(player)
signal wall_bounced

@onready var hit_sound: AudioStreamPlayer = $HitSound

@export var speed:float = 300.0
@export var minSpeed:float = 250.0
@export var maxSpeed:float = 1000.0

@export var paddleInfluence:float = 0.5
@export var speedIncrement:float = 20.0

@export var rotationSpeed:float = 0.5
@export var rotationAcceleration:float = 1.0
@export var maxRotationSpeed:float = 10.0

var start_position: Vector2

func _ready() -> void:
	start_position = global_position
	velocity = Vector2(1, -1).normalized() * speed

func reset():
	global_position = start_position
	velocity = Vector2.ZERO
	rotation = 0.5

func _physics_process(delta: float) -> void:
	rotation += rotationSpeed * delta
	var collision = move_and_collide(velocity * delta)
	
	if global_position.x < 0:
		goal.emit(2)
	elif global_position.x > 1152:
		goal.emit(1)
	
	if collision:
		hit_sound.play()
		
		var collider = collision.get_collider()
		
		if collider.is_class("CharacterBody2D"):
			hit_paddle(collider)
		else:
			velocity = velocity.bounce(collision.get_normal())
			wall_bounced.emit()

func hit_paddle(paddle:CharacterBody2D):
	var relativeHit = (global_position.y - paddle.global_position.y) / (paddle.height / 2.0)
	relativeHit = clamp(relativeHit, -1.0, 1.0)
	var direction_x = 1.0
	
	if paddle.global_position.x < global_position.x:
		direction_x = 1.0
	else: 
		direction_x = -1.0
	
	var direction_y = relativeHit
	direction_y += (paddle.velocity.y/speed) * paddleInfluence
	
	var direction = Vector2(direction_x, direction_y).normalized()
	
	var current_speed = velocity.length()
	var new_speed = clamp(
		current_speed + speedIncrement,
		minSpeed,
		maxSpeed
	)
	
	velocity = direction * new_speed
	
	if paddle.velocity.y < 0:
		rotationSpeed -= rotationAcceleration
	elif paddle.velocity.y > 0:
		rotationSpeed += rotationAcceleration
	
	rotationSpeed = clamp(rotationSpeed, -maxRotationSpeed, maxRotationSpeed)

func start():
	var angle = randf_range(-45.0, 45.0)
	var direction = Vector2(
		cos(deg_to_rad(angle)),
		sin(deg_to_rad(angle))
	)
	
	if randf() < 0.5:
		direction.x *= -1
		
	velocity = direction.normalized() * speed
