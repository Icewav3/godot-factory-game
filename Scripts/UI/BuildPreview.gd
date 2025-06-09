extends Node2D

@onready var icon: Sprite2D = $PreviewSprite
var modulate_value

func set_texture(texture: Texture2D) -> void:
	icon.texture = texture

func set_valid(valid: bool) -> void:
	if valid:
		modulate_value = Color(1, 1, 1, 0.5)
	else:
		modulate_value = Color(1, 0, 0, 0.5)
	icon.modulate = modulate_value
