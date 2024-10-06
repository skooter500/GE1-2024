extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 10

var controlling = true

@export var rot_speed = 180

var relative:Vector2 = Vector2.ZERO

func print_stuff():
	DebugDraw2D.set_text("position", position)
	DebugDraw2D.set_text("global_position", position)
	DebugDraw2D.set_text("rotation", rotation)
	DebugDraw2D.set_text("global_rotation", global_rotation)

	DebugDraw2D.set_text("basis.x", transform.basis.x)
	DebugDraw2D.set_text("basis.y", transform.basis.y)
	DebugDraw2D.set_text("basis.z", transform.basis.z)
	DebugDraw2D.set_text("global basis.x", global_transform.basis.x)
	DebugDraw2D.set_text("global basis.y", global_transform.basis.y)
	DebugDraw2D.set_text("global basis.z", global_transform.basis.z)



func _input(event):
	if event is InputEventMouseMotion and controlling:
		relative = event.relative
	if event.is_action_pressed("ui_cancel"):
		if controlling:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:			
			Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		controlling = ! controlling

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	pass # Replace with function body.
	

func _physics_process(delta: float) -> void:
	
	print_stuff()
	
	rotate(Vector3.DOWN, deg_to_rad(relative.x * deg_to_rad(rot_speed) * delta))
	rotate(transform.basis.x,deg_to_rad(relative.y * deg_to_rad(rot_speed) * delta))
	relative = Vector2.ZERO


	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY


	# walk
	var w = Input.get_axis("move_back", "move_forward")
	if w:
		var dir = global_transform.basis.z
		dir.y = 0
		dir = dir.normalized()
		velocity += w * dir

	# strafe
	var s = Input.get_axis("turn_left", "turn_right")
	if s:
		velocity -= s * global_transform.basis.x * SPEED

	# damping
	velocity *= 0.9
	
	move_and_slide()
