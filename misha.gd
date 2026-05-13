extends CharacterBody3D

var speed := 8.0
var speed_increase := 0.5
var max_speed := 20.0
var lanes := [-3.0, 0.0, 3.0]
var current_lane := 1
var target_x := 0.0
var jump_velocity := 10.0
var gravity := 20.0
var is_jumping := false
var alive := true
var currency := 0

# Платок
var platok_active := false
var platok_timer := 0.0
var platok_duration := 10.0
@onready var platok_mesh = $платок
@onready var platok_sound = $ПлатокSound

var swipe_start := Vector2.ZERO
var swipe_threshold := 50.0
var is_swiping := false

func _ready():
	target_x = lanes[current_lane]
	add_to_group("misha_group")
	# Платок невидимый по умолчанию
	if platok_mesh:
		platok_mesh.visible = false

func _physics_process(delta):
	if not alive:
		return
	
	# Таймер платка
	if platok_active:
		platok_timer -= delta
		if platok_timer <= 0.0:
			_deactivate_platok()
	
	speed = min(speed + speed_increase * delta, max_speed)
	velocity.z = -speed
	velocity.x = 0.0
	
	target_x = lanes[current_lane]
	
	var pos = position
	pos.x = lerp(pos.x, target_x, delta * 10.0)
	position = pos
	
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		is_jumping = false
	
	move_and_slide()

func _input(event):
	if not alive:
		return
	
	if event is InputEventScreenTouch:
		if event.pressed:
			swipe_start = event.position
			is_swiping = true
		else:
			if is_swiping:
				handle_swipe(event.position)
			is_swiping = false
	
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			swipe_start = event.position
			is_swiping = true
		elif not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			if is_swiping:
				handle_swipe(event.position)
			is_swiping = false
	
	if event.is_action_pressed("ui_left"):
		move_left()
	elif event.is_action_pressed("ui_right"):
		move_right()
	elif event.is_action_pressed("ui_accept"):
		jump()

func handle_swipe(end_pos: Vector2):
	var swipe = end_pos - swipe_start
	if abs(swipe.x) > abs(swipe.y):
		if swipe.x > swipe_threshold:
			move_right()
		elif swipe.x < -swipe_threshold:
			move_left()
	else:
		if swipe.y < -swipe_threshold:
			jump()

func move_left():
	if current_lane > 0:
		current_lane -= 1
		target_x = lanes[current_lane]

func move_right():
	if current_lane < 2:
		current_lane += 1
		target_x = lanes[current_lane]

func jump():
	if is_on_floor():
		velocity.y = jump_velocity
		is_jumping = true

func activate_platok():
	platok_active = true
	platok_timer = platok_duration
	max_speed = 35.0
	if platok_mesh:
		platok_mesh.visible = true
	if platok_sound:
		platok_sound.play()

func _deactivate_platok():
	platok_active = false
	max_speed = 20.0
	if platok_mesh:
		platok_mesh.visible = false

func die():
	# Если платок активен - не умираем а играем звук столкновения
	if platok_active:
		if platok_sound:
			platok_sound.play()
		return
	
	print("DIE ВЫЗВАН!")
	if not alive:
		print("УЖЕ МЁРТВ")
		return
	alive = false
	print("НАЧИНАЕМ ЖДАТЬ 4 СЕК")
	await get_tree().create_timer(4.0).timeout
	if not is_inside_tree():
		print("НЕ В ДЕРЕВЕ")
		return
	print("ОТКРЫВАЕМ МЕНЮ")
	var game_over = load("res://game_over.tscn").instantiate()
	get_tree().root.add_child(game_over)

func add_currency(amount: int):
	currency += amount
	print("Бабки: ", currency, " 💰")
