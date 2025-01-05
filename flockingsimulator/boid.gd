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
	self.fov = _fov
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
		if neighbour == null: break
		var ind = indicator_scene.instantiate()
		ind.initialize(self.position, neighbour.position)
		indicator_list.append(ind)
		add_sibling(ind)
	for i in range(indicator_list.size()):
		indicator_list[i].update(self.position, neighbours[i].position)
	$SelectionIndicator.show()

func deselect():
	selected = false
	for indicator in indicator_list:
		indicator.queue_free()
	indicator_list.clear()
	$SelectionIndicator.hide()

func toggle_select():
	if selected: deselect()
	else: select()

func compare_dist(a, b):
	if a == null:
		return false
	return (a.position - self.position).length() < (b.position - self.position).length()

#func aquire_neighbours(): # Without fov limits
	#neighbours.clear()
	#neighbours.resize(neighbours_no)
	#for n in range(neighbours_no):
		#var r = randi() % boid_list.size()
		#while (boid_list[r] == self || boid_list[r] in neighbours):
			#r = randi() % boid_list.size()
		#neighbours[n] = boid_list[r]

func within_fov(boid): # check if the given boid is within this boids fov
	if boid == null: return false
	return Quaternion(self.transform.basis.z, boid.position - self.position).get_angle() < fov/2

func aquire_neighbours(): # With fov limits
	neighbours.clear()
	neighbours.resize(neighbours_no)
	
	#var no_possible = false
	var possible_boids : Array
	for boid in boid_list:
		if within_fov(boid) and boid != self:
			possible_boids.append(boid)
	
	for n in range(neighbours_no):
		if possible_boids.size() == 0: break
		var r = randi() % possible_boids.size()
		#neighbours[n] = possible_boids[r]
		neighbours.append(possible_boids[r])
		possible_boids.remove_at(r)
	
	neighbours = neighbours.filter(func(num): return num != null)

func reaquire_neighbours():
	var possible_boids : Array
	var p_b_aquired = false # only calculate in view boids if necessary and only once
	neighbours.resize(neighbours_no)
	
	for n in range(neighbours.size()):
		if !within_fov(neighbours[n]):
			if !p_b_aquired:
				for boid in boid_list:
					if within_fov(boid) and boid not in neighbours and boid != self:
						possible_boids.append(boid)
				p_b_aquired = true
			neighbours[n] = null
	for n in range(neighbours.size()):
		if possible_boids.size() == 0: break
		if neighbours[n] == null:
			var r = randi() % possible_boids.size()
			neighbours[n] = possible_boids[r]
			possible_boids.remove_at(r)
	
	neighbours = neighbours.filter(func(num): return num != null)

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
	if aquire_count == 60:
		aquire_count -= 60
		reaquire_neighbours()
		if selected:
			deselect()
			select()
	aquire_count += 1
	
	if selected:
		for i in range(indicator_list.size()):
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
	#target_velocity.z *= 0.5 # tend towards horizontal (TODO not working)
	
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
		for n in neighbours.size():
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
