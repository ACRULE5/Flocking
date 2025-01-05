extends CharacterBody3D

const RAY_LENGTH = 1000
var speed = 100
var mouse_sensitivity = 0.005
var rot_x = PI
var rot_y = 0

var ground

var camera_enabled

func _ready():
	$Camera.current = true
	camera_enabled = true
	ground = get_parent().find_child("Ground")

var target_velocity = Vector3.ZERO

func _physics_process(_delta):
	move()
	
func move():
	var direction = Vector3.ZERO
	
	if Input.is_action_pressed("move_right"):
		direction.x += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_forward"):
		direction.z -= 1
	if Input.is_action_pressed("move_backward"):
		direction.z += 1
	if Input.is_action_pressed("move_up"):
		direction.y += 1
	if Input.is_action_pressed("move_down"):
		direction.y -= 1
	
	if direction != Vector3.ZERO:
		direction = direction.normalized()
	
	target_velocity.x = direction.x * speed
	target_velocity.z = direction.z * speed
	target_velocity.y = direction.y * speed
	
	target_velocity = target_velocity.rotated(Vector3(0,1,0), rot_x)
	
	velocity = target_velocity
	move_and_slide()

# Raycast from mouse
func pick_boid():
	var space_state = get_world_3d().direct_space_state
	var camera = $Camera
	#var centre = get_viewport().get_size()/2
	var centre = get_viewport().get_mouse_position()
	var origin = camera.project_ray_origin(centre)
	var end = origin + camera.project_ray_normal(centre) * RAY_LENGTH
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.exclude = [ground]
	var result = space_state.intersect_ray(query)
	if result.is_empty(): return
	else:
		var picked = result["collider"]
		picked.toggle_select()

func _input(event):
	if camera_enabled and event is InputEventMouseMotion:
		rot_x -= event.relative.x * mouse_sensitivity
		rot_y -= event.relative.y * mouse_sensitivity
		rot_y = clamp(rot_y, -PI/2, PI/2)
		transform.basis = Basis()
		$Camera.transform.basis = Basis()
		rotate_object_local(Vector3(0,1,0), rot_x)
		$Camera.rotate_object_local(Vector3(1,0,0), rot_y)
	
	if !camera_enabled and event is InputEventMouseButton and event.pressed and event.button_index == 1:
		pick_boid()
	
	if event.is_action_pressed("pause"):
		get_tree().paused = !get_tree().paused
	if event.is_action_pressed("show_crosshair"):
		camera_enabled = false
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if event.is_action_released("show_crosshair"):
		camera_enabled = true
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
