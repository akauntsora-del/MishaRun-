extends CanvasLayer

@onready var timer_label = $Panel/TimerLabel
@onready var restart_button = $Panel/RestartButton
@onready var menu_button = $Panel/MenuButton

var countdown := 10.0

func _ready():
	# Замораживаем игру
	get_tree().paused = true
	
	restart_button.pressed.connect(_on_restart)
	menu_button.pressed.connect(_on_menu)
	
	# Сам CanvasLayer работает даже при паузе
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(delta):
	countdown -= delta
	timer_label.text = str(ceil(countdown))
	
	if countdown <= 0:
		_on_restart()

func _on_restart():
	get_tree().paused = false
	queue_free()
	get_tree().reload_current_scene()

func _on_menu():
	get_tree().paused = false
	queue_free()
	get_tree().change_scene_to_file("res://main_menu.tscn")
