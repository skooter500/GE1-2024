extends CharacterBody3D

@export var speed:float = -1
@export var rot_speed = 180.0

@export var bullet_scene:PackedScene
@export var bullet_spawn:Node3D

@export var fire_rate:int = 10

@onready  var timer = $Timer

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

func _time_out():
	can_fire = true

func _ready() -> void:
	timer.wait_time = 1.0 / fire_rate
	timer.connect("timeout", _time_out)
	pass 

var can_fire:bool = true

func _physics_process(delta: float) -> void:

	print_stuff()

	# Other ways of moving by manipulating the transform	
	# position.z += speed * delta
	# global_position.z += speed * delta
	
	var f = Input.get_axis("move_back", "move_forward")
	
	var v = Vector3()	
	v = global_transform.basis.z # My direction vector	
	velocity = v * speed * f
	
	move_and_slide()
	
	var r = Input.get_axis("turn_left", "turn_right")
	
	rotate_y(- deg_to_rad(rot_speed) * r * delta)
	# rotate_y()
	# rotate_y(deg_to_rad(rot_speed) * delta)
	# rotate_x(deg_to_rad(rot_speed) * delta)
	
	
	if can_fire and Input.is_action_pressed("shoot"):
		var bullet = bullet_scene.instantiate()
		get_parent().add_child(bullet)
		can_fire = false
		bullet.global_position = bullet_spawn.global_position
		bullet.global_rotation = global_rotation
		timer.start()
	pass
