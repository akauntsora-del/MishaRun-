extends CharacterBody3D

@onready var misha = get_tree().get_first_node_in_group("misha_group")

var gravity := 20.0
var phase := 0
var lanes := [-3.0, 0.0, 3.0]
var current_lane := 1
var target_x := 0.0
var bak_timer := 0.0
var bak_interval := 2.5

@export var trash_scene: PackedScene

func _ready():
	add_to_group("bukhanka_group")
	await get_tree().process_frame
	
	var misha_lane = _get_misha_lane()
	var other_lanes = []
	for i in range(3):
		if i != misha_lane:
			other_lanes.append(i)
	current_lane = other_lanes[randi() % other_lanes.size()]
	target_x = lanes[current_lane]
	
	position.x = target_x
	position.z = misha.position.z + 25.0
	position.y = 1.0

func _get_misha_lane() -> int:
	var closest := 0
	var closest_dist := 999.0
	for i in range(3):
		var d = abs(misha.position.x - lanes[i])
		if d < closest_dist:
			closest_dist = d
			closest = i
	return closest

func _physics_process(delta):
	if misha == null:
		return
	
	velocity.x = 0.0
	
	match phase:
		0:
			velocity.z = misha.velocity.z * 1.5
			position.x = lerp(position.x, target_x, delta * 8.0)
			
			if position.z <= misha.position.z:
				phase = 1
				current_lane = _get_misha_lane()
				target_x = lanes[current_lane]
		
		1:
			velocity.z = misha.velocity.z * 1.2
			position.x = lerp(position.x, target_x, delta * 5.0)
			
			if position.z < misha.position.z - 25.0:
				phase = 2
		
		2:
			velocity.z = misha.velocity.z
			current_lane = _get_misha_lane()
			target_x = lanes[current_lane]
			position.x = lerp(position.x, target_x, delta * 5.0)
			
			bak_timer += delta
			if bak_timer >= bak_interval:
				bak_timer = 0.0
				_spawn_baks()
		
		3:
			# Просто едет прямо вперёд и исчезает
			velocity.z = misha.velocity.z * 3.0
			
			if position.z < misha.position.z - 200.0:
				queue_free()
	
	position.z += velocity.z * delta
	position.y += velocity.y * delta
	
	if position.y > 1.0:
		velocity.y -= gravity * delta
	else:
		position.y = 1.0
		velocity.y = 0.0

func _spawn_baks():
	if trash_scene == null:
		return
	
	var count = randi() % 2 + 2
	var shuffled_lanes = lanes.duplicate()
	shuffled_lanes.shuffle()
	
	for i in range(count):
		var trash = trash_scene.instantiate()
		get_parent().add_child(trash)
		trash.position.z = position.z + randf_range(2.0, 6.0)
		trash.position.x = shuffled_lanes[i]
		trash.position.y = 2.0
		trash.add_to_group("trash")
		var rb = trash.get_node_or_null("TrashCan")
		if rb and rb.has_method("apply_central_impulse"):
			rb.apply_central_impulse(Vector3(randf_range(-2.0, 2.0), 3.0, randf_range(5.0, 10.0)))

func _start_escape():
	phase = 3
	print("БУХАНКА УЕЗЖАЕТ! 🚐")

func _on_hit_area_body_entered(body):
	if body.is_in_group("person"):
		body._get_hit(self)
	if body.is_in_group("scooter"):
		body.velocity = Vector3(randf_range(-8.0, 8.0), 12.0, -8.0)
	if body.is_in_group("trash"):
		var rb = body.get_node_or_null("TrashCan")
		if rb and rb.has_method("apply_central_impulse"):
			rb.apply_central_impulse(Vector3(randf_range(-5.0, 5.0), 10.0, -8.0))
