extends Node
class_name Snap

static func snap_to_grid(global_position: Vector2, tilemap_layer: TileMapLayer, centered := true) -> Vector2:
	var cell = tilemap_layer.local_to_map(global_position)
	var snapped_pos = tilemap_layer.map_to_local(cell)

	if centered:
		var tile_size = tilemap_layer.tile_set.tile_size
		# Accumulate scale from the tilemap's global_transform
		var global_scale = tilemap_layer.global_transform.get_scale()
		snapped_pos += (tile_size * 0.5) * global_scale

	return snapped_pos
