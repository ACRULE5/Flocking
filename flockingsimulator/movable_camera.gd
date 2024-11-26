extends CharacterBody3D

var speed = 100
var mouse_sensitivity = 0.005
var rot_x = PI
var rot_y = 0

func _ready():
	$Camera.current = true

var target_velocity = Vector3.ZERO

func _physics_process(_delta):
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


func _input(event):
	if event is InputEventMouseMotion:
		rot_x -= event.relative.x * mouse_sensitivity
		rot_y -= event.relative.y * mouse_sensitivity
		rot_y = clamp(rot_y, -PI/2, PI/2)
		transform.basis = Basis()
		$Camera.transform.basis = Basis()
		rotate_object_local(Vector3(0,1,0), rot_x)
		$Camera.rotate_object_local(Vector3(1,0,0), rot_y)
