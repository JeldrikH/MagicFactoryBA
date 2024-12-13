extends PanelContainer
class_name RecipePanel

@export var recipe_grid: GridContainer
signal button_create(button: Button, index: int)
signal back



func open():
	update()
	visible = true

func update():
	for recipe in recipe_grid.get_children():
		recipe.queue_free()
	for i in get_parent().inventory_data.recipe_list.size():
		var button = Button.new()
		button.icon = get_parent().inventory_data.recipe_list[i].result_image
		button.text = get_parent().inventory_data.recipe_list[i].name
		button_create.emit(button, i)
		recipe_grid.add_child(button)

func _on_back_pressed() -> void:
	back.emit()
