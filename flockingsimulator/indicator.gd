extends Node3D

var source : Vector3
var target : Vector3


func initialize(_source, _target):
	update(_source, _target)

func update(_source, _target):
	self.source = _source
	self.target = _target

func _process(_delta: float) -> void:
	var displacement = (target - source).length()
	$MeshInstance3D.scale.y = displacement
	$MeshInstance3D.position.z = -displacement/2
	look_at_from_position(source, target, Vector3(0,1,0))
