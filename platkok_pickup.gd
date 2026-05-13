extends Area3D

func _ready():
	body_entered.connect(_on_body_entered)
	# Покачиваемся для красоты
	var tween = create_tween().set_loops()
	tween.tween_property($Sprite, "position:y", 0.5, 0.8)
	tween.tween_property($Sprite, "position:y", 0.0, 0.8)

func _on_body_entered(body):
	if body.name == "Misha":
		body.activate_platok()
		queue_free()
