extends CanvasLayer

func get_key(action_name: StringName) -> String:
	var input_events = InputMap.action_get_events(action_name)
	var key: String = OS.get_keycode_string(input_events[0].physical_keycode)
	return key

func show_interaction():
	%InteractionLabel.show()

func hide_interaction():
	%InteractionLabel.hide()
