extends CharacterBody3D

@onready var crash_sound = $CrashSound
@onready var scream_sound = $ScreamSound
@onready var mesh = $бомжара

var gravity := 20.0
var lanes := [-3.0, 0.0, 3.0]
var current_lane := 1
var target_x := 0.0
var alive := true
var walk_speed := 3.0

var lane_change_timer := 0.0
var lane_change_interval := 2.0

var spin_speed := Vector3.ZERO

func _ready():
	current_lane = randi() % 3
	target_x = lanes[current_lane]
	position.x = target_x
	add_to_group("person")

func _physics_process(delta):
	if not alive:
		velocity.y -= gravity * delta
		move_and_slide()
		mesh.rotation += spin_speed * delta
		return
	
	velocity.z = walk_speed
	position.x = lerp(position.x, target_x, delta * 5.0)
	
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	move_and_slide()
	
	lane_change_timer += delta
	if lane_change_timer >= lane_change_interval:
		lane_change_timer = 0.0
		lane_change_interval = randf_range(1.5, 4.0)
		current_lane = randi() % 3
		target_x = lanes[current_lane]
	
	if position.z > 50:
		queue_free()

func _on_hit_area_body_entered(body):
	if not alive:
		return
	
	if body.name == "Misha" or body.is_in_group("scooter") or body.is_in_group("trash") or body.name == "Syringe":
		_get_hit(body)

func _get_hit(hitter):
	alive = false
	
	crash_sound.play()
	scream_sound.play()
	
	$CollisionShape3D.set_deferred("disabled", true)
	
	velocity = Vector3(randf_range(-4.0, 4.0), 5.0, randf_range(-8.0, -15.0))
	
	spin_speed = Vector3(
		randf_range(10.0, 20.0) * (1.0 if randf() > 0.5 else -1.0),
		randf_range(8.0, 15.0) * (1.0 if randf() > 0.5 else -1.0),
		randf_range(12.0, 25.0) * (1.0 if randf() > 0.5 else -1.0)
	)
	
	if hitter and hitter.name == "Misha":
		hitter.add_currency(10)
	
	await get_tree().create_timer(3.0).timeout
	queue_free()
