extends MeshInstance3D

@onready var tank:Node3D = $"../tank"
var to_player: Vector3
var forw: Vector3
var axis: Vector3
var theta: float
var q1: Quaternion
var q2: Quaternion
var t = 0
var is_rotating = false

func _ready() -> void:
	start_slerp()

func start_slerp():

	to_player = tank.global_position - global_position
	to_player = to_player.normalized()
	
	forw = -global_transform.basis.z
	forw = forw.normalized()	
	axis = forw.cross(to_player)
	
	if axis.length_squared() < 0.001:
		is_rotating = false
		return
		
	axis = axis.normalized()
	theta = forw.angle_to(to_player)
	
	q1 = global_transform.basis.get_rotation_quaternion()
	q2 = Quaternion(axis, theta) * q1	
	q2 = Basis().looking_at(to_player, global_basis.y)	
	
	t = 0
	is_rotating = true

func _process(delta: float) -> void:
	# Debug visualization
	DebugDraw3D.draw_arrow(global_position, global_position + -global_transform.basis.z * 5, Color.AQUA, 0.1)  # Current forward
	DebugDraw3D.draw_arrow(global_position, global_position + to_player * 5, Color.RED, 0.1)  # Direction to player
	
	if Input.is_action_just_pressed("slerp"):
		start_slerp()
	
	if is_rotating:
		if t < 1.0:
			t += delta
			t = minf(t, 1.0)
			
			# Apply rotation
			var q = q1.slerp(q2, t)
			global_transform.basis = Basis(q)
			
			DebugDraw2D.set_text("t", t)
		else:
			is_rotating = false
