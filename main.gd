extends Node3D

@export var road_tile_scene: PackedScene
@export var misha: Node3D
@export var scooter_scene: PackedScene
@export var trash_can_scene: PackedScene
@export var person_scene: PackedScene
@export var bukhanka_scene: PackedScene
@export var platok_scene: PackedScene

var tile_length := 20.0
var tiles_ahead := 15
var last_tile_z := 0.0

var spawn_timer := 0.0
var spawn_interval := 3.0

var trash_timer := 0.0
var trash_interval := 2.0

var person_timer := 0.0
var person_interval := 1.5

var platok_timer := 0.0
var platok_interval := 15.0

var lanes := [-3.0, 0.0, 3.0]

var distance := 0.0
var start_z := 0.0
var bukhanka_spawned := false
var bukhanka_returned := false

func _ready():
	for i in range(tiles_ahead):
		spawn_tile(-i * tile_length)
	last_tile_z = -(tiles_ahead - 1) * tile_length

func _process(delta):
	if misha == null:
		return
	
	if start_z == 0.0:
		start_z = misha.position.z
	
	distance = abs(misha.position.z - start_z)
	
	while last_tile_z > misha.position.z - (tiles_ahead * tile_length):
		last_tile_z -= tile_length
		spawn_tile(last_tile_z)
	
	for tile in get_children():
		if tile.has_method("check_delete"):
			tile.check_delete(misha.position.z)
	
	if not bukhanka_spawned or bukhanka_returned:
		spawn_timer += delta
		if spawn_timer >= spawn_interval:
			spawn_timer = 0.0
			spawn_scooter()
	
	if not bukhanka_spawned or bukhanka_returned:
		trash_timer += delta
		if trash_timer >= trash_interval:
			trash_timer = 0.0
			spawn_trash()
	
	person_timer += delta
	if person_timer >= person_interval:
		person_timer = 0.0
		spawn_person()
	
	# Спавн платка с небольшим шансом
	platok_timer += delta
	if platok_timer >= platok_interval:
		platok_timer = 0.0
		if randf() < 0.4:
			spawn_platok()
	
	if distance >= 500.0 and not bukhanka_spawned:
		bukhanka_spawned = true
		_spawn_bukhanka()
	
	if distance >= 1000.0 and bukhanka_spawned and not bukhanka_returned:
		bukhanka_returned = true
		_return_syringe()

func spawn_tile(z_pos: float):
	var tile = road_tile_scene.instantiate()
	add_child(tile)
	tile.position.z = z_pos

func spawn_scooter():
	if scooter_scene == null:
		return
	
	var blocked_lanes := []
	for child in get_children():
		if child.is_in_group("trash"):
			for i in range(3):
				if abs(child.position.x - lanes[i]) < 0.5:
					if i not in blocked_lanes:
						blocked_lanes.append(i)
	
	var free_lanes := []
	for i in range(3):
		if i not in blocked_lanes:
			free_lanes.append(i)
	
	var chosen_lane: int
	if blocked_lanes.size() > 0 and randf() < 0.4:
		chosen_lane = blocked_lanes[randi() % blocked_lanes.size()]
	else:
		if free_lanes.size() > 0:
			chosen_lane = free_lanes[randi() % free_lanes.size()]
		else:
			chosen_lane = randi() % 3
	
	var scooter = scooter_scene.instantiate()
	add_child(scooter)
	scooter.position.z = misha.position.z - 60.0
	scooter.position.x = lanes[chosen_lane]

func spawn_trash():
	if trash_can_scene == null:
		return
	var trash = trash_can_scene.instantiate()
	add_child(trash)
	trash.position.z = misha.position.z - 50.0
	trash.position.x = lanes[randi() % 3]
	trash.position.y = 1.0
	trash.add_to_group("trash")

func spawn_person():
	if person_scene == null:
		return
	var person = person_scene.instantiate()
	add_child(person)
	person.position.z = misha.position.z - 40.0
	person.position.y = 1.0

func spawn_platok():
	if platok_scene == null:
		return
	var platok = platok_scene.instantiate()
	add_child(platok)
	platok.position.z = misha.position.z - 30.0
	platok.position.x = lanes[randi() % 3]
	platok.position.y = 1.5

func _spawn_bukhanka():
	print("СПАВНИМ БУХАНКУ! Дистанция: ", distance)
	var syringe = get_node_or_null("Syringe")
	if syringe:
		syringe.visible = false
		syringe.set_physics_process(false)
	
	if bukhanka_scene == null:
		print("БУХАНКА СЦЕНА NULL!")
		return
	var b = bukhanka_scene.instantiate()
	add_child(b)
	# Ищем CharacterBody3D внутри Node3D
	var bukhanka_body = b.get_node_or_null("Bukhanka")
	if bukhanka_body:
		bukhanka_body.trash_scene = trash_can_scene
	else:
		# Если скрипт на самом Node3D
		if b.has_method("_start_escape"):
			b.set("trash_scene", trash_can_scene)
	print("БУХАНКА ДОБАВЛЕНА!")

func _return_syringe():
	var b = get_tree().get_first_node_in_group("bukhanka_group")
	print("БУХАНКА НАЙДЕНА: ", b)
	if b and b.has_method("_start_escape"):
		b._start_escape()
	
	await get_tree().create_timer(3.0).timeout
	var syringe = get_node_or_null("Syringe")
	if syringe:
		syringe.visible = true
		syringe.set_physics_process(true)
		syringe.position.z = misha.position.z + 5.0
