extends Node2D

@onready var sprite1 = $Sprite1
@onready var sprite2 = $Sprite2
@onready var sprite3 = $Sprite3

func _ready():
	animate_blast()

func animate_blast():
	# Sprite 1 - Cyan - Começa imediatamente
	var tween1 = create_tween().set_parallel(true)
	tween1.tween_property(sprite1, "scale", Vector2(3.5, 3.5), 0.25).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween1.tween_property(sprite1, "modulate:a", 0.0, 0.3).set_ease(Tween.EASE_IN)
	tween1.tween_property(sprite1, "rotation", PI * 0.5, 0.3)

	# Sprite 2 - Branco - Delay de 0.05s
	await get_tree().create_timer(0.05).timeout
	var tween2 = create_tween().set_parallel(true)
	tween2.tween_property(sprite2, "scale", Vector2(3.0, 3.0), 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween2.tween_property(sprite2, "modulate:a", 0.0, 0.35).set_ease(Tween.EASE_IN)
	tween2.tween_property(sprite2, "rotation", sprite2.rotation - PI * 0.3, 0.3)

	# Sprite 3 - Azul claro - Delay adicional de 0.05s
	await get_tree().create_timer(0.05).timeout
	var tween3 = create_tween().set_parallel(true)
	tween3.tween_property(sprite3, "scale", Vector2(2.5, 2.5), 0.35).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween3.tween_property(sprite3, "modulate:a", 0.0, 0.4).set_ease(Tween.EASE_IN)
	tween3.tween_property(sprite3, "rotation", sprite3.rotation + PI * 0.8, 0.35)

	# Auto-destruir após animação completa
	await get_tree().create_timer(0.5).timeout
	queue_free()
