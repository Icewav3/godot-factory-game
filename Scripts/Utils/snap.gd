# Utils/Snap.gd
extends Node

class_name Snap

static func snap_to_grid(global_position: Vector2, tilemap: TileMap) -> Vector2:
	var cell = tilemap.world_to_map(global_position)
	return tilemap.map_to_world(cell) + tilemap.cell_size * 0.5
