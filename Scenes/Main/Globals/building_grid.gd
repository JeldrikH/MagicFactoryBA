extends Node2D

var current_scene: Node2D

var grid_activated = false

var grid_spacing = 40
var line_width = 2
var line_opacity = 0.2
## Amount of lines in each direction
var grid_size = 40
var test = true

## grid_position line of points, ranging from top left to bottom right of the screen
var grid_position: Array[Vector2i]

## even index: vertical lines, odd index: horizontal lines
var grid: Array[Line2D]


func _physics_process(_delta):
	if grid_activated:
		move_grid(get_local_mouse_position())

func instantiate_grid():
	grid_activated = true
	var building_grid = current_scene.get_node("BuildingGrid")
	grid = []
	for i in 8 * grid_size: # 2 Directions * 2 Orientations * 2 Initial position arrays in x shape
		var line = Line2D.new()
		line.width = line_width
		line.default_color = Color("7EEDDF", line_opacity)
		line.show()
		grid.append(line)
		building_grid.add_child(line)

func deactivate_grid():
	grid_activated = false
	for line in grid:
		line.queue_free()
	grid = []
		
func move_grid(center_position: Vector2i):
	var w_n_point = get_first_line_positions(center_position)
	calculate_grid(w_n_point)
	var line_positions = get_line_positions(grid_position)
	draw_lines(line_positions)
	

func draw_lines(line_positions: Array):
	for i in line_positions.size():
		grid[i].set_points(PackedVector2Array([line_positions[i][0], line_positions[i][1]]))

## Returns Vector2(west, north). the closest northwest grid_position point of the given location
func get_first_line_positions(point_position: Vector2i)-> Vector2i:
	var north = round_down(point_position.y)
	var west = round_down(point_position.x)
	return Vector2i(west, north)
	
func round_down(coordinate: int)-> int:
	var diff = coordinate % grid_spacing
	return coordinate - diff

## 2 Initial position arrays in x shape merged together in grid_position array
func calculate_grid(point: Vector2i):
	grid_position = []
	for i in range(-grid_size, grid_size):
		grid_position.append(Vector2i(point.x +(grid_spacing * i), point.y +(grid_spacing * i)))
	for i in range(-grid_size, grid_size):
		grid_position.append(Vector2i(point.x +(grid_spacing * i), point.y -(grid_spacing * i)))

func get_line_positions(positions: Array[Vector2i])-> Array:
	var line_positions = []
	for line in positions:
		var h_line = []
		var v_line = []
		v_line.append(Vector2i(line.x, line.y - (DisplayServer.screen_get_size().y))) # N
		v_line.append(Vector2i(line.x, line.y + (DisplayServer.screen_get_size().y))) # S
		h_line.append(Vector2i(line.x + (DisplayServer.screen_get_size().x), line.y)) # E
		h_line.append(Vector2i(line.x - (DisplayServer.screen_get_size().x), line.y)) # W
		
		line_positions.append(v_line)
		line_positions.append(h_line)
	return line_positions

## Calculate the closest point in the grid for build snap
func get_closest_point(current_position:  Vector2i)-> Vector2i:
	var diff_x = current_position.x % grid_spacing
	var diff_y = current_position.y % grid_spacing
	var new_position: Vector2i
	@warning_ignore("integer_division")
	if diff_x < grid_spacing / 2:
		new_position.x = current_position.x - diff_x
	else:
		new_position.x = current_position.x + grid_spacing - diff_x
	@warning_ignore("integer_division")
	if diff_y < grid_spacing / 2:
		new_position.y = current_position.y - diff_y
	else:
		new_position.y = current_position.y + grid_spacing - diff_y
	return new_position
