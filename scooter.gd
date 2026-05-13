extends CharacterBody3D

@onready var engine_sound = $EngineSound
@onready var crash_sound = $CrashSound
@onready var misha_scream = $MishaScream

var speed := 15.0
var gravity := 20.0

func _ready():
	engine_sound.play()
	add_to_group("scooter")

func _physics_process(delta):
	velocity.z = speed
	
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	move_and_slide()
	
	if position.z > 50:
		queue_free()

func _on_hit_area_body_entered(body):
	if body.name == "Misha":
		engine_sound.stop()
		crash_sound.play()
		misha_scream.play()
		speed = 0.0
		
		if body.platok_active:
			# Платок активен - самокат отлетает а Миша едет дальше
			velocity = Vector3(randf_range(-8.0, 8.0), 15.0, 10.0)
			var scooter_mesh = get_node("скутерку")
			if scooter_mesh:
				var tween = create_tween()
				tween.tween_property(scooter_mesh, "rotation", Vector3(PI, randf_range(-PI, PI), PI), 0.5)
			return
		
		body.velocity = Vector3(randf_range(-5.0, 5.0), 15.0, 5.0)
		velocity = Vector3(randf_range(-5.0, 5.0), 12.0, 8.0)
		
		var misha_mesh = body.get_node("Bear_Mesh")
		var scooter_mesh = get_node("скутерку")
		
		if misha_mesh:
			var tween = create_tween()
			tween.tween_property(misha_mesh, "rotation", Vector3(PI, randf_range(-PI, PI), PI), 0.5)
		
		if scooter_mesh:
			var tween2 = create_tween()
			tween2.tween_property(scooter_mesh, "rotation", Vector3(PI, randf_range(-PI, PI), PI), 0.5)
		
		body.die()
