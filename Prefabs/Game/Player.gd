# ====================
# Player.gd
# ====================
# Player movement script with world boundary constraints accounting for sprite size
extends Node2D

@export var acceleration: float = 750  # How fast the player accelerates
@export var max_speed: float = 300     # Maximum movement speed
@export var drag: float = 0.975        # Drag coefficient (0.0 = no drag, 1.0 = no movement)
@export var sprite: Sprite2D
@export_category("Camera Zoom")
@export var camera: Camera2D
@export var min_zoom: float = 0.5
@export var max_zoom: float = 1
@export var zoom_increment: float = 0.05
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
	
func _unhandled_input(event: InputEvent) -> void:
	handle_zoom_input()
func handle_zoom_input() -> void:
	if not camera:
		return
	
	var zoom_delta: float = 0.0
	
	# Check for zoom input actions
	if Input.is_action_pressed("zoom_in"):
		zoom_delta = zoom_increment
	elif Input.is_action_pressed("zoom_out"):
		zoom_delta = -zoom_increment
	
	# Apply zoom if there's input
	if zoom_delta != 0.0:
		var current_zoom = camera.zoom.x
		var new_zoom = current_zoom + zoom_delta
		
		# Clamp zoom to min/max values
		new_zoom = clampf(new_zoom, min_zoom, max_zoom)
		
		# Apply the new zoom
		camera.zoom = Vector2(new_zoom, new_zoom)
# Get normalized input from player actions
func get_input() -> Vector2:
	return Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	)
