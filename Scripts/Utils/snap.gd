# Scripts/Utils/Snap.gd
extends Node
class_name Snap

static func snap_to_grid(
		global_position: Vector2,
		layer: TileMapLayer        # Godot 4.4 API
) -> Vector2:
	# 1. World -> layer‑local
	var local_pos := layer.to_local(global_position)

	# 2. Layer‑local -> cell coords
	var cell_coords := layer.local_to_map(local_pos)

	# 3. Cell coords -> layer‑local *center*  (already centred)
	var snapped_local := layer.map_to_local(cell_coords)

	# 4. Back to world
	return layer.to_global(snapped_local)
