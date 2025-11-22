# ====================
# Player.gd
# ====================
# Player movement script with world boundary constraints accounting for sprite size
extends Node2D

@export var acceleration: float = 750  # How fast the player accelerates
@export var max_speed: float = 300     # Maximum movement speed
@export var drag: float = 0.975        # Drag coefficient (0.0 = no drag, 1.0 = no movement)
@export var sprite: Sprite2D
var velocity: Vector2 = Vector2.ZERO

func _physics_process(delta: float) -> void:
	var input_vector := get_input().normalized()
	
	# Apply speed limiting before acceleration
	if velocity.length() > max_speed:
		velocity = velocity.normalized() * max_speed
	else:
		# Accelerate based on input
		if input_vector != Vector2.ZERO:
			velocity += input_vector * acceleration * delta
		else:
			# Apply drag when no input (gradual slowdown)
			velocity *= drag
	
	# Update position using global coordinates (important for world bounds)
	global_position += velocity * delta
	
	# Constrain player to world boundaries accounting for sprite size
	# This ensures the entire sprite stays within the defined tilemap area
	if WorldBounds.is_initialized:
		var rect = get_child(0).get_rect()
		var half_size = rect.size * 0.5
		global_position = WorldBounds.clamp_position_with_size(global_position, half_size)
func _process(delta: float) -> void:
	if velocity.length() > 0.1:
		sprite.rotation = velocity.angle() + PI/2

# Get normalized input from player actions
func get_input() -> Vector2:
	return Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	)
