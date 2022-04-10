extends KinematicBody

onready var Camera = $Pivot/Camera

var gravity = -30
var max_speed = 8
var mouse_sensitivity = 0.002
var mouse_range = 1.2 
var velocity = Vector3()

var controlled = false

var id = 0

func _ready():
	if (name == "Player1" and Global.which_player == 1) or (name == "Player2" and Global.which_player == 2):
		controlled = true
	$MeshInstance.set_surface_material(0, $MeshInstance.get_surface_material(0).duplicate)
	if name == "Player1":
		$MeshInstance.get_surface_material(0).albedo_color = Color8(34, 139, 230)
	else:
		$MeshInstance.get_surface_material(0).albedo_color = Color8(258, 82,82, 230)
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	#$Pivot/Camera.current = true
	pass

func get_input():
	var input_dir = Vector3.ZERO
	if Input.is_action_pressed("forward"):
		input_dir += -Camera.global_transform.basis.z
	if Input.is_action_pressed("back"):
		input_dir += Camera.global_transform.basis.z
	if Input.is_action_pressed("left"):
		input_dir += -Camera.global_transform.basis.x
	if Input.is_action_pressed("right"):
		input_dir += Camera.global_transform.basis.x
	input_dir = input_dir.normalized()
	return input_dir
	
func _unhandled_input(event):
	if controlled and event is InputEventMouseMotion:
		$Pivot.rotate_x(-event.relative.y * mouse_sensitivity)
		rotate_y(-event.relative.x * mouse_sensitivity)
		$Pivot.rotation.x = clamp($Pivot.rotation.x, -mouse_range, mouse_range)
		rpc_unreliable("_set_rotation", rotation, $Pivot.rotation)
	
	
func _physics_process(delta):
	if controlled:
		velocity.y += gravity * delta
		var desired_velocity = get_input() * max_speed
		
		
		velocity.x = desired_velocity.x
		velocity.z = desired_velocity.z
		velocity = move_and_slide(velocity, Vector3.ZERO, true)
		rpc_unreliable("_set_position", global_transform.origin)
	
remote func _set_position(pos):
	if not controlled:
		global_transform.origin = pos

remote func _set_rotation(rot, piv_rot):
	if not controlled:
		rotation = rot
		$Pivot.rotation = piv_rot
