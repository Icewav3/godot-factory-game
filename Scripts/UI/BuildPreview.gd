extends Node2D

@onready var icon: Sprite2D = $PreviewSprite
@export var material_list: VBoxContainer
@export var material_slot_scene: PackedScene
var modulate_value

#Paranoia checking cuz this has been causing me to crash out
func _ready() -> void:
	icon.centered = true
	icon.offset   = Vector2.ZERO
	icon.position = Vector2.ZERO

func set_texture(texture: Texture2D) -> void:
	icon.texture = texture

func set_valid(valid: bool) -> void:
	if valid:
		modulate_value = Color(1, 1, 1, 0.5)
	else:
		modulate_value = Color(1, 0, 0, 0.5)
	icon.modulate = modulate_value

func _draw() -> void:
	var size := Vector2(256, 256)
	var half := size * 0.5
	draw_rect(Rect2(-half, size), Color.RED, false)
	draw_circle(Vector2.ZERO, 10, Color.GREEN)  # Should be in the center of red box
	
func set_required_materials(materials: Dictionary) -> void:
	for child in material_list.get_children():
		child.queue_free()


	for current_res in materials.keys():
		var amount: int = materials[current_res]
		var slot = material_slot_scene.instantiate()
		var icon = slot.get_node("Icon")
		var label = slot.get_node("Count")
		#label.add_theme_color_override("font_color", Color.RED)
		icon.texture = current_res.sprite
		label.text = "-%d" % amount

		slot.tooltip_text = current_res.material_name
		material_list.add_child(slot)
