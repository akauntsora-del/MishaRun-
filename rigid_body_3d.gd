extends RigidBody3D

@onready var crash_sound = $CrashSound
@onready var misha_scream = $MishaScream

func _ready():
	$HitArea.body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.name == "Misha":
		crash_sound.play()
		misha_scream.play()
		
		if body.platok_active:
			# Платок активен - бак отлетает
			apply_central_impulse(Vector3(randf_range(-5.0, 5.0), 8.0, -10.0))
			return
		
		body.die()
		var bear_mesh = body.get_node("Bear_Mesh")
		if bear_mesh:
			var tween = create_tween()
			tween.tween_property(bear_mesh, "rotation", Vector3(PI, 0, 0), 0.4)
	
	if body.is_in_group("scooter"):
		crash_sound.play()
		apply_central_impulse(Vector3(randf_range(-3.0, 3.0), 8.0, -5.0))
