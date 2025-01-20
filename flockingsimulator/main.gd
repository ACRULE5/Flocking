extends Node

@export var boid_scene : PackedScene

var boid_list : Array

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	Engine.max_fps = 60
	
	if $Parameters.seed != 0: seed($Parameters.seed)
	
	for i in $Parameters.no_of_boids:
		var boid = boid_scene.instantiate()
		var location = Vector3()
		
		var spawn_area_size = $SpawnArea/CollisionShape3D.shape.size
		var spawn_area_pos = $SpawnArea.position
		location.x = randf_range(spawn_area_pos.x-spawn_area_size.x/2, spawn_area_pos.x+spawn_area_size.x/2)
		location.y = randf_range(spawn_area_pos.y-spawn_area_size.y/2, spawn_area_pos.y+spawn_area_size.y/2)
		location.z = randf_range(spawn_area_pos.z-spawn_area_size.z/2, spawn_area_pos.z+spawn_area_size.z/2)
		
		var rot_x = randf_range(0, 2*PI)
		var rot_y = randf_range(0, 2*PI)
		
		#var speed = randf_range($Parameters.boid_min_speed, $Parameters.boid_max_speed)
		
		#Create boid
		boid.initialize(location,
		#speed,
		$Parameters.boid_acceleration,
		$Parameters.boid_turn_speed,
		rot_x,
		rot_y,
		$Parameters.boid_neighbours,
		$Parameters.boid_min_distance,
		($Parameters.boid_fov * PI / 180),
		boid_list,
		$Parameters.align_weight,
		$Parameters.attract_weight,
		$Parameters.repulse_weight
		)
		
		boid_list.append(boid)
		add_child(boid)

# every frame
func _process(_delta: float) -> void:
	update_bounding_box()

# Get the max and min coordinates of all the birds and update the bounding box
func update_bounding_box():
	var max_x
	var min_x
	var max_y
	var min_y
	var max_z
	var min_z
	for boid in boid_list:
		if max_x == null:
			max_x = boid.position.x
			min_x = boid.position.x
			max_y = boid.position.y
			min_y = boid.position.y
			max_z = boid.position.z
			min_z = boid.position.z
			continue
		if boid.position.x > max_x: max_x = boid.position.x
		if boid.position.x < min_x: min_x = boid.position.x
		if boid.position.y > max_y: max_y = boid.position.y
		if boid.position.y < min_y: min_y = boid.position.y
		if boid.position.z > max_z: max_z = boid.position.z
		if boid.position.z < min_z: min_z = boid.position.z
	$BoundingBox.update(max_x, min_x, max_y, min_y, max_z, min_z)
	
	var b_box_vol = $BoundingBox.get_volume()
	# Show bbox volume in the ui
	$UserInterface/BoundingBoxVolume.text = "Bounding Box Volume: " + str(round(b_box_vol)) + "m^3"
	if Engine.get_process_frames() % 60 == 0: # print bbox volume every second
		print(round(b_box_vol))

# If the button to display the bounding box is toggled, toggle accordingly
func _on_bounding_box_button_toggled(toggled_on):
	if toggled_on:
		$BoundingBox.show()
	else:
		$BoundingBox.hide()

# Select/deselect all buttons
func _on_select_all_button_pressed():
	for boid in boid_list:
		boid.deselect()
		boid.select()
func _on_deselect_all_button_pressed():
	for boid in boid_list:
		boid.deselect()
