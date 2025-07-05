extends HBoxContainer

func _on_toggle_button_toggled(toggled_on: bool) -> void:
	visible = toggled_on
	var filter_val: int
	if toggled_on:
		filter_val = Control.MOUSE_FILTER_STOP
	else:
		filter_val = Control.MOUSE_FILTER_IGNORE

	propagate_call("set_mouse_filter", [filter_val])
