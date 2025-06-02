# Utils/Snap.gd
extends Node
class_name Snap

static func snap_to_grid(global_position: Vector2, tilemap_layer: TileMapLayer, centered := true) -> Vector2:
	var cell = tilemap_layer.local_to_map(global_position)
	var snapped_pos = tilemap_layer.map_to_local(cell)

	if centered:
		snapped_pos += Vector2(tilemap_layer.tile_set.tile_size * 0.25)

	return snapped_pos
