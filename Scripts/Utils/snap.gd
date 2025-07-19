# Scripts/Utils/Snap.gd
extends Node
class_name snap

static func snap_to_grid(global_position: Vector2, layer: TileMapLayer) -> Vector2:
	if not layer or not is_instance_valid(layer):
		push_warning("snap_to_grid: TileMapLayer is null or invalid, returning original position")
		return global_position
	# 1. World -> layer‑local
	var local_pos := layer.to_local(global_position)

	# 2. Layer‑local -> cell coords
	var cell_coords := layer.local_to_map(local_pos)

	# 3. Cell coords -> layer‑local *center*  (already centred)
	var snapped_local := layer.map_to_local(cell_coords)

	# 4. Back to world
	return layer.to_global(snapped_local)
