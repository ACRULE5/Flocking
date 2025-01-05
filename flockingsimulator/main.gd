extends Node

@export var boid_scene : PackedScene

var boid_list : Array

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	#seed(12345)
	
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
		$Parameters.boid_angle_noise,
		$Parameters.boid_speed_noise,
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
	
	#boid_list[(randi() % $Parameters.no_of_boids)].select()


func _process(_delta: float) -> void:
	# bounding box calc
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
