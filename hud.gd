extends CanvasLayer

@onready var coins_label = $CoinsLabel
@onready var distance_label = $DistanceLabel

var misha = null
var start_z := 0.0
var started := false

func _process(_delta):
	if misha == null:
		# Ищем Мишу каждый кадр пока не найдём
		misha = get_tree().get_first_node_in_group("misha_group")
		return
	
	if not started:
		start_z = misha.position.z
		started = true
	
	coins_label.text = "💰 " + str(misha.currency)
	var distance = int(abs(misha.position.z - start_z))
	distance_label.text = "📏 " + str(distance) + "м"
