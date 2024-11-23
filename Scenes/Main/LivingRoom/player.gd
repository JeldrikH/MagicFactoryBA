extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0


func _physics_process(_delta: float) -> void:

	# Get the input direction and handle the movement/deceleration.
	var xAxis := Input.get_axis("MOVE_LEFT", "MOVE_RIGHT")
	var yAxis := Input.get_axis("MOVE_UP","MOVE_DOWN")
	if xAxis or yAxis:
		velocity.x = xAxis * SPEED
		velocity.y = yAxis * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.y = move_toward(velocity.y, 0, SPEED)

	move_and_slide()
	
