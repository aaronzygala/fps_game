extends Node3D

func spawn(pos: Vector3, normal: Vector3):
	position = pos
	if normal != Vector3.UP:
		# look in the direction of the normal
		look_at(pos + normal, Vector3.UP)
		# then look "up" from there so the decal projects "down"
		global_transform = transform.rotated_local(Vector3.RIGHT, PI/2.0)
	rotate(normal, randf_range(0, 2*PI))
