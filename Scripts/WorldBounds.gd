# ===== WORLD BOUNDS SYSTEM =====
# A static class system for managing world boundaries based on TileMapLayer bounds
# Allows any script to access world limits for player movement, camera constraints, etc.

# ====================
# WorldBounds.gd
# ====================
# Attach this script to the parent node containing your TileMapLayer children
# This creates a static class that calculates and stores world boundaries

class_name WorldBounds
extends Node2D

# Static variables - shared across all instances and accessible globally
static var bounds: Rect2              # The calculated world boundary rectangle
static var is_initialized: bool = false  # Safety flag to prevent usage before initialization

# Calculates world bounds from a specific TileMapLayer child named "GroundLayer"
# Called automatically in _ready(), but can be called manually if tilemap changes
static func initialize_from_tilemap_layers(tilemap_parent: Node):
	# Look for the specific GroundLayer child
	var ground_layer = tilemap_parent.get_node("GroundLayer")
	
	if not ground_layer or not ground_layer is TileMapLayer:
		push_error("GroundLayer not found or is not a TileMapLayer!")
		return
	
	var layer = ground_layer as TileMapLayer
	var map_rect = layer.get_used_rect()  # Gets bounding box of all placed tiles
	
	if map_rect.size == Vector2i.ZERO:
		push_warning("GroundLayer has no tiles!")
		return
	
	# Get tile size to calculate precise boundaries
	var tile_size = layer.tile_set.tile_size
	
	# map_rect gives us tile coordinates, we need world coordinates
	# map_rect.position = top-left tile coordinate
	# map_rect.position + map_rect.size = one tile past bottom-right
	var top_left_tile = map_rect.position
	var bottom_right_tile = map_rect.position + map_rect.size
	
	# Convert tile coordinates to world coordinates
	# We subtract tile_size * 0.5 because map_to_local() returns tile centers,
	# but we want the actual corners for precise boundaries
	var global_start = layer.to_global(layer.map_to_local(top_left_tile) - tile_size * 0.5)
	var global_end = layer.to_global(layer.map_to_local(bottom_right_tile) - tile_size * 0.5)
	
	# Store the calculated bounds
	bounds = Rect2(global_start, global_end - global_start)
	is_initialized = true
	
	# Debug output for verification
	print("Tile size: ", tile_size)
	print("Map rect (tile coords): ", map_rect)
	print("World bounds initialized: ", bounds)
	print("World spans from: ", bounds.position, " to: ", bounds.position + bounds.size)

# Public API functions for accessing bounds data
static func get_bounds() -> Rect2:
	if not is_initialized:
		push_warning("WorldBounds not initialized!")
		return Rect2()
	return bounds

static func get_min_pos() -> Vector2:
	return bounds.position

static func get_max_pos() -> Vector2:
	return bounds.position + bounds.size

# Clamps a position to stay within world bounds - useful for player movement
static func clamp_position(pos: Vector2) -> Vector2:
	if not is_initialized:
		return pos
	return Vector2(
		clamp(pos.x, bounds.position.x, bounds.position.x + bounds.size.x),
		clamp(pos.y, bounds.position.y, bounds.position.y + bounds.size.y)
	)

# Clamps a position accounting for sprite size - ensures entire sprite stays within bounds
static func clamp_position_with_size(pos: Vector2, half_size: Vector2) -> Vector2:
	if not is_initialized:
		return pos
	return Vector2(
		clamp(pos.x, bounds.position.x + half_size.x, bounds.position.x + bounds.size.x - half_size.x),
		clamp(pos.y, bounds.position.y + half_size.y, bounds.position.y + bounds.size.y - half_size.y)
	)

# Initialize bounds when this node is ready
func _ready():
	WorldBounds.initialize_from_tilemap_layers(self)
