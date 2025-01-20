extends Node3D


func update(max_x, min_x, max_y, min_y, max_z, min_z):
	var size_x = max_x - min_x
	var size_y = max_y - min_y
	var size_z = max_z - min_z
	var position_x = (max_x + min_x)/2
	var position_y = (max_y + min_y)/2
	var position_z = (max_z + min_z)/2
	
	$MeshInstance3D.mesh.size = Vector3(size_x, size_y, size_z)
	position = Vector3(position_x, position_y, position_z)
	#print($MeshInstance3D.scale)
	#print(position)

func get_volume():
	return $MeshInstance3D.mesh.size.x * $MeshInstance3D.mesh.size.y * $MeshInstance3D.mesh.size.z
