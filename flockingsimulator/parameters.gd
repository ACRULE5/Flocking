extends Node

@export var no_of_boids = 100
@export var boid_acceleration = 0.6
@export var boid_turn_speed = 0.05
@export var boid_angle_noise = 0.1
@export var boid_speed_noise = 0.5
@export var boid_neighbours = 7
@export var boid_min_distance = 5
@export var boid_fov = 5/3*PI
@export var align_weight = 0.1
@export var attract_weight = 3
@export var repulse_weight = 2
