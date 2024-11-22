extends CharacterBody3D

@export var indicator_scene : PackedScene
var indicator_list : Array

var acceleration
var speed_noise
var rot : Vector3
var turn_speed
var angle_noise
var neighbours_no
var boid_list : Array
var min_distance
var fov

var neighbours : Array
#var speed
var align_weight
var attract_weight
var repulse_weight

var aquire_count # timer to reaquire neighbours, random phase so all boids don't do so at once

var selected

func initialize(_start_position, _acceleration,
	_turn_speed, _angle_noise, _speed_noise, _rot_x, _rot_y, _neighbours, _min_distance, _fov, _boid_list,
	_align_weight, _attract_weight, _repulse_weight):
	position = _start_position
	#self.speed = _start_speed
	self.acceleration = _acceleration
	self.turn_speed = _turn_speed
	self.angle_noise = _angle_noise
	self.speed_noise = _speed_noise
	self.rot = Vector3(0,0,0)
	self.rot.x = _rot_x
	self.rot.y = _rot_y
	self.rot.z = 0 # TODO maybe
	self.neighbours_no = _neighbours
	self.min_distance = _min_distance
	self.boid_list = _boid_list
	self.align_weight = _align_weight
	self.attract_weight = _attract_weight
	self.repulse_weight = _repulse_weight
	self.aquire_count = randi() % 60
	
	self.selected = false
	
	transform.basis = Basis()
	rotate_object_local(Vector3(0,1,0), rot.x)
	rotate_object_local(Vector3(1,0,0), rot.y)
	velocity = transform.basis.z * acceleration

func select():
	selected = true
	for neighbour in neighbours:
		var ind = indicator_scene.instantiate()
		ind.initialize(self.position, neighbour.position)
		indicator_list.append(ind)
		add_sibling(ind)

## Get average direction from all neighbours within certain radius
#func consider_neighbours_metric():
	#var avg_angle_x = rot_x
	#var avg_angle_y = rot_y
	#var count = 1
	#for boid in boid_list:
		#if boid == self:
			#continue
		#if (boid.position - self.position).length() < 10:
			#avg_angle_x = avg_angle_x + boid.rot_x
			#avg_angle_y = avg_angle_y + boid.rot_y
			#count += 1
	#avg_angle_x = avg_angle_x / count + randf_range(-noise/2, noise/2)
	#avg_angle_y = avg_angle_y / count + randf_range(-noise/2, noise/2)
	#return Vector3(avg_angle_x, avg_angle_y, 0)

func compare_dist(a, b):
	if a == null:
		return false
	return (a.position - self.position).length() < (b.position - self.position).length()

#func aquire_neighbours():
	#neighbours.clear()
	#neighbours.resize(neighbours_no)
	#for boid in boid_list:
		#if boid == self:
			#continue
		#for n in neighbours_no - 1:
			#if neighbours[n] == null:
				#neighbours[n] = boid
				#neighbours.sort_custom(compare_dist)
				#break
			#else:
				##var d = (boid.position - self.position).length()
				#var place = neighbours.bsearch_custom(boid, compare_dist)
				#if place < neighbours_no:
					#neighbours.insert(place, boid)
					#neighbours.resize(neighbours_no)

func aquire_neighbours():
	neighbours.clear()
	neighbours.resize(neighbours_no)
	for n in range(neighbours_no):
		var r = randi() % boid_list.size()
		while (boid_list[r] == self || boid_list[r] in neighbours):
			r = randi() % boid_list.size()
		neighbours[n] = boid_list[r]

func align_with_neighbours() -> Vector3:
	var target = Vector3(self.velocity)
	for boid in neighbours:
		target += boid.velocity
	return target.normalized()

func avoid_collision() -> Vector3:
	var target = Vector3(0,0,0)
	for boid in boid_list:
		var from_boid = self.position - boid.position # vector from boid to self
		if from_boid.length() < min_distance:
			target += from_boid.normalized()
		#target += from_boid.normalized() * 5 * (3 ** (-from_boid.length() - min_distance))
	if self.position.y < 10:
		target += Vector3(0,10,0)
	#if self.position.y > 40: target += Vector3(0,-0.2,0)
	return target.normalized()

func move_towards_neighbours() -> Vector3:
	var target = Vector3(0,0,0)
	var avg_pos = Vector3(self.position)
	var count = 1
	for boid in neighbours:
		avg_pos += boid.position
		count += 1
	avg_pos /= count
	target = avg_pos - self.position
	return target.normalized()

func _physics_process(_delta: float):
	if neighbours.size() < 1:# || aquire_count == 60:
		#aquire_count -= 60
		aquire_neighbours()
		if selected: select()
	#aquire_count += 1
	
	if selected:
		for i in range(neighbours_no):
			indicator_list[i].update(self.position, neighbours[i].position)
	
	var target_velocity_neighbours = align_with_neighbours()
	var target_velocity_attraction = move_towards_neighbours()
	var target_velocity_collision = avoid_collision()
	
	var target_velocity = ( # Total target attraction, weighted
		+ (target_velocity_neighbours * align_weight)
		+ (target_velocity_attraction * attract_weight)
		+ (target_velocity_collision * repulse_weight)
		)
	
	if target_velocity == Vector3(0,0,0): target_velocity = Vector3(0,0,1) # mostly for testing
	
	target_velocity = target_velocity.normalized()
	target_velocity.z *= 0.5 # tend towards horizontal
	
	var target = Quaternion(Vector3(0,0,1).normalized(), target_velocity.normalized()).normalized().get_euler()
	
	# Turn towards target angle, limited by turn speed
	if abs(target.y - rot.x) < turn_speed:
		rot.x = target.y
	elif target.y < rot.x:
		rot.x -= turn_speed
	else:
		rot.x += turn_speed
	
	if abs(target.x - rot.y) < turn_speed:
		rot.y = target.x
	elif target.x < rot.y:
		rot.y -= turn_speed
	else:
		rot.y += turn_speed
	
	if abs(target.z - rot.z) < turn_speed:
		rot.z = target.z
	elif target.z < rot.z:
		rot.z -= turn_speed
	else:
		rot.z += turn_speed
	
	#if abs(target.z - speed) < acceleration:
		#speed = target.z
	#elif target.z < speed:
		#speed -= acceleration
	#else:
		#speed += acceleration
	
	
	if selected:
		for n in neighbours_no:
			var ind = indicator_list[n]
			var neighbour = neighbours[n]
			ind.update(self.position, neighbour.position)
	
	
	transform.basis = Basis()
	rotate_object_local(Vector3(0,1,0), rot.x)
	rotate_object_local(Vector3(1,0,0), rot.y)
	rotate_object_local(Vector3(0,0,1), rot.z)
	velocity *= 0.97
	velocity += transform.basis.z * acceleration
	move_and_slide()
