extends PanelContainer
class_name Slot
@onready var item_texture: TextureRect = $SlotMargin/ItemTexture
@onready var quantity_label: Label = $QuantityLabel
@export var index: int
@export var color_default = Color(0.9, 0.9, 1, 0.32)
@export var color_hovered = Color(0.9, 0.9, 1, 0.5)
@export var is_selected = false
@export var is_drag_drop_target = false
@export var is_hovered = false
@export var is_hotbar_slot = false
@export var contains_item = false
signal transfer

@export var tooltip_delay = 1
var tooltip: RichTextLabel
var tooltip_content: String

#Sets the Background Color of the Item Slot
func _ready() -> void:
	add_to_group("slots")
	self["theme_override_styles/panel"] = StyleBoxFlat.new()
	self["theme_override_styles/panel"].bg_color = color_default

#Highlight focussed Slot
func _process(_delta: float) -> void:
	if is_hovered:
		read_inputs()
		tooltip_follow_cursor()
	check_for_item_deleting()


#Sets the Item Contents of the Slot
func set_slot_data(slot_data: SlotData):
	set_selected(false)
	is_drag_drop_target = false
	if slot_data.item:
		$SlotMargin/ItemTexture.texture = slot_data.item.icon
		tooltip_content = "[b]" + tr(slot_data.item.name) + "[/b]\n\n" + tr(slot_data.item.description)
	else:
		$SlotMargin/ItemTexture.texture = null
		
	if slot_data.quantity >= 1:
		$QuantityLabel.text = str(slot_data.quantity)
		contains_item = true
	else:
		$QuantityLabel.text = ""
		contains_item = false
		

func set_selected(p_is_selected: bool):
	is_selected = p_is_selected
	if is_hotbar_slot:
		$SlotMargin/SelectTexture.visible = p_is_selected
	
func toggle_selected():
	is_selected = not is_selected
	$SlotMargin/SelectTexture.visible = not $SlotMargin/SelectTexture.visible
	
	
#Catch Signal on hover and change Background respectively
func _on_mouse_entered() -> void:
	self["theme_override_styles/panel"].bg_color = color_hovered
	is_hovered = true
	activate_tooltip()
	
func _on_mouse_exited() -> void:
	self["theme_override_styles/panel"].bg_color = color_default
	is_hovered = false
	deactivate_tooltip()
	
func _on_delay_timeout() -> void:
		tooltip.visible = true
	
func activate_tooltip():
	tooltip = RichTextLabel.new()
	tooltip.visible = false
	tooltip.text = tooltip_content
	tooltip.fit_content = true
	tooltip.autowrap_mode = TextServer.AUTOWRAP_OFF
	tooltip.bbcode_enabled = true
	tooltip["theme_override_styles/normal"] = StyleBoxFlat.new()
	tooltip["theme_override_styles/normal"].bg_color = color_default
	$TooltipLayer.add_child(tooltip)
	$TooltipLayer/Delay.start(tooltip_delay)
	
func deactivate_tooltip():
	tooltip.queue_free()
	$TooltipLayer/Delay.stop()

func tooltip_follow_cursor():
	if tooltip:
		tooltip.position = get_viewport().get_mouse_position() + Vector2(20,0)
	
func read_inputs():
	if Input.is_action_just_pressed("TRANSFER_ITEM") and contains_item:
		transfer.emit()
		return
		
	if Input.is_action_just_pressed("CLICK") and (contains_item or is_hotbar_slot):
		set_selected(true)
	
	if Input.is_action_just_released("CLICK") and not is_hotbar_slot:
		is_drag_drop_target = true

## Is item dragged out of the inventory?
func check_for_item_deleting():
	if contains_item and is_selected and Input.is_action_just_released("CLICK") and not Globals.mouse_inside_inventory and not is_hotbar_slot:
		get_tree().call_group("delete_prompt", "open_prompt", get_parent(), index)
