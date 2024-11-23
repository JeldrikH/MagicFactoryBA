extends PanelContainer
class_name RecipePanel

@export var recipe_grid: GridContainer
signal button_create(button: Button, recipe: Recipe)
signal back



func open():
	update()
	visible = true

func update():
	for recipe in recipe_grid.get_children():
		recipe.queue_free()
	for recipe in get_parent().recipe_list:
		var button = Button.new()
		button.icon = recipe.result_image
		button.text = recipe.name
		button_create.emit(button, recipe)
		recipe_grid.add_child(button)

func _on_back_pressed() -> void:
	back.emit()
