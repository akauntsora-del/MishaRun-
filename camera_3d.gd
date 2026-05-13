extends Camera3D

@export var offset := Vector3(0, 3, 8)
@export var smooth_speed := 5.0

var target: CharacterBody3D

func _ready():
	target = get_parent().get_node("Misha")

func _process(delta):
	if not target:
		return
	
	var desired_position = target.global_transform.origin + target.global_transform.basis * offset
	global_transform.origin = desired_position
	look_at(target.global_transform.origin, Vector3.UP)
