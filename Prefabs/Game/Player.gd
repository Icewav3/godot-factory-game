extends Node2D

@export var acceleration: float = 750
@export var max_speed: float = 300
@export var drag: float = 0.975

var velocity: Vector2 = Vector2.ZERO

func _physics_process(delta: float) -> void:
	var input_vector := get_input().normalized()
	

	# Clamp to max speed
	if velocity.length() > max_speed:
		velocity = velocity.normalized() * max_speed
	else:
		# Accelerate if input is given
		if input_vector != Vector2.ZERO:
			velocity += input_vector * acceleration * delta
		else:
			# Apply drag
			velocity *= drag
	# Update pos
	position += velocity * delta

func get_input() -> Vector2:
	return Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	)
