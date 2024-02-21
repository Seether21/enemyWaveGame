extends CharacterBody2D

@onready var visuals = $Visuals

@export var base_speed: int = 125
@export var base_acceleration: float = 20



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var movement_vector = get_movement_vector()
	var direction = movement_vector.normalized()
	var desired_velocity = direction * base_speed
	velocity = velocity.lerp(desired_velocity, 1 - exp(-base_acceleration * get_process_delta_time())) 
	move_and_slide()
	
	var move_sign = sign(movement_vector.x)
	if move_sign != 0:
		visuals.scale = Vector2(move_sign, 1)
	
	if movement_vector != Vector2.ZERO:
		$Visuals/AnimatedSprite2D.play("walk")
	else: 
		$Visuals/AnimatedSprite2D.play("idle")


func get_movement_vector():
	
	var x_movement = Input.get_action_strength("move_right")- Input.get_action_strength("move_left")
	var y_movement = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
		
	return Vector2(x_movement, y_movement)
