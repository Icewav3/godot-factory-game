extends Node

var current_buildable

func _on_build_menu_panel_build_button_pressed(data: buildable_data) -> void:
	current_buildable = data
	print("Selected via signal: ", data.building_name)


func _on_toggle_button_toggled(toggled_on: bool) -> void:
	if toggled_on == false:
		current_buildable = null
