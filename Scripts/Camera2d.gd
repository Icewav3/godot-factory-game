# ====================
# Camera2D.gd (Smart Following Camera)
# ====================
# Camera that follows the player while respecting world boundaries
# Keeps player centered when possible, "hugs" edges when at world boundaries

extends Camera2D

@export var player: Node2D             # Reference to player node (assign in inspector)
@export var follow_speed: float = 5.0  # Camera follow smoothness (0 = instant, higher = smoother)
@export_category("Camera Zoom")
@export var min_zoom: float = 0.5
@export var max_zoom: float = 1
@export var zoom_increment: float = 0.05

func _ready():
	# Wait one frame to ensure WorldBounds is initialized first
	await get_tree().process_frame
	
	if WorldBounds.is_initialized:
		setup_camera_limits()

func _process(delta):
	if player:
		follow_player(delta)

func _unhandled_input(event: InputEvent) -> void:
	handle_zoom_input()
func handle_zoom_input() -> void:
	var camera = self
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
		
# Core camera following logic with boundary constraints
func follow_player(delta):
	if not WorldBounds.is_initialized:
		return
	
	# Get current viewport dimensions
	var viewport_size = get_viewport().get_visible_rect().size
	var half_viewport = viewport_size * 0.5 / zoom  # Account for camera zoom
	
	# Calculate where camera should be to center player in view
	# Important: Camera2D anchor point is top-left, so we offset by half viewport
	# to center the player in the camera view
	var target_pos = player.global_position - half_viewport
	
	# Get world boundaries
	var world_bounds = WorldBounds.get_bounds()
	var world_min = world_bounds.position
	var world_max = world_bounds.position + world_bounds.size
	
	# Clamp camera position to prevent showing areas outside world bounds
	# Camera top-left cannot go below world minimum
	# Camera top-left cannot go above (world maximum - viewport size)
	# This ensures the camera view never shows empty space beyond the tilemap
	var clamped_pos = Vector2(
		clamp(target_pos.x, world_min.x, world_max.x - viewport_size.x / zoom.x),
		clamp(target_pos.y, world_min.y, world_max.y - viewport_size.y / zoom.y)
	)
	
	# Apply camera movement (smooth or instant)
	if follow_speed <= 0:
		# Instant follow - camera snaps to position immediately
		global_position = clamped_pos
	else:
		# Smooth follow - camera lerps to position over time
		global_position = global_position.lerp(clamped_pos, follow_speed * delta)

# Set up hard camera limits as a backup constraint
# Usually not needed with the clamping above, but provides extra safety
func setup_camera_limits():
	var bounds = WorldBounds.get_bounds()
	limit_left = int(bounds.position.x)
	limit_top = int(bounds.position.y) 
	limit_right = int(bounds.position.x + bounds.size.x)
	limit_bottom = int(bounds.position.y + bounds.size.y)
