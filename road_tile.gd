extends Node3D

# Когда тайл уходит далеко за камеру - удаляем его
func check_delete(player_z: float):
	if position.z > player_z + 30:
		queue_free()
