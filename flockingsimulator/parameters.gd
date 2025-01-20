extends Node

@export var seed = 0 # 0 For random seed
@export var no_of_boids = 100
@export var boid_acceleration = 0.3
@export var boid_turn_speed = 0.05
@export var boid_neighbours = 7
@export var boid_min_distance = 20
@export var boid_fov = 360 # in degrees
@export var align_weight = 1.0
@export var attract_weight = 1.0
@export var repulse_weight = 1.0
