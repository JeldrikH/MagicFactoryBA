extends RichTextLabel

func _ready() -> void:
	update_keys()
	hide()
	
func update_keys():
	_interaction_label()
	
func _interaction_label():
	var key = %UI.get_key("INTERACT")
	text = tr("INTERACTION_LABEL").format({"key" : key})
	
