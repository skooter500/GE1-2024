extends Node3D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

@export var score = 0
@export var speed:float = 10
@export var rot_speed =0.5
var controlling = true

var relative:Vector2 = Vector2.ZERO

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

@export var can_move:bool = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	rotate(Vector3.DOWN, deg_to_rad(relative.x * deg_to_rad(rot_speed) * delta))
	rotate(transform.basis.x,deg_to_rad(- relative.y * deg_to_rad(rot_speed) * delta))
	relative = Vector2.ZERO
	if can_move:
		var v = Vector3.ZERO
		
		var mult = 1
		if Input.is_key_pressed(KEY_SHIFT):
			mult = 3
		
		var turn = Input.get_axis("turn_left", "turn_right") - v.x	
		if abs(turn) > 0:   
			position = position + global_transform.basis.x * speed * turn * mult * delta
			# global_translate(global_transform.basis.x * speed * turn * mult * delta)
		
		var movef = Input.get_axis("move_forward", "move_back")
		if abs(movef) > 0:     
			global_translate(global_transform.basis.z * speed * movef * mult * delta)
		
		var upanddown = Input.get_axis("move_up", "move_down")
		if abs(upanddown) > 0:     
			global_translate(- global_transform.basis.y * speed * upanddown * mult * delta)


func _on_area_3d_area_entered(area):
	score += 1
	print("Score: ", score)
