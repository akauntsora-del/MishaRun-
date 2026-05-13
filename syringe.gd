extends CharacterBody3D

@onready var misha = get_parent().get_node("Misha")
var crash_sound: AudioStreamPlayer3D

func _ready():
	crash_sound = get_node_or_null("CrashSound")

var gravity := 20.0
var is_attacking := false

enum State {CHASING, RISING, DIVING, FINISHED}
var state = State.CHASING

var target_above_misha := Vector3.ZERO

func _physics_process(delta):
	if misha == null:
		return
	
	match state:
		State.CHASING:
			velocity.z = misha.velocity.z * 1.1
			position.x = lerp(position.x, misha.position.x, delta * 3.0)
			position.z = lerp(position.z, misha.position.z + 3.0, delta * 5.0)
			
			if not is_on_floor():
				velocity.y -= gravity * delta
			
			if not misha.alive and not is_attacking:
				is_attacking = true
				target_above_misha = Vector3(misha.position.x, misha.position.y + 6.0, misha.position.z)
				state = State.RISING
		
		State.RISING:
			position = position.lerp(target_above_misha, delta * 3.0)
			
			if position.distance_to(target_above_misha) < 0.3:
				rotation.x = deg_to_rad(-90)
				rotation.z = deg_to_rad(0)
				state = State.DIVING
		
		State.DIVING:
			var dive_target = Vector3(misha.position.x, misha.position.y, misha.position.z)
			position = position.lerp(dive_target, delta * 10.0)
			
			if position.distance_to(dive_target) < 0.2:
				state = State.FINISHED
				_finish()
		
		State.FINISHED:
			pass

func _on_hit_area_body_entered(body):
	if body.is_in_group("trash"):
		crash_sound.play()

func _finish():
	set_physics_process(false)
	await get_tree().create_timer(0.5).timeout
	misha.die()
