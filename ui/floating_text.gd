extends Label

@export var float_speed: float = 50.0
@export var float_distance: float = 80.0
@export var duration: float = 1.0

func _ready():
	# Configurar z-index para aparecer acima de tudo
	z_index = 100

	# Animação: sobe + fade out
	var start_pos = position
	var end_pos = start_pos + Vector2(randf_range(-20, 20), -float_distance)

	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "position", end_pos, duration).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "modulate:a", 0.0, duration).set_ease(Tween.EASE_IN)

	# Pequeno scale bounce no início
	scale = Vector2(0.5, 0.5)
	var scale_tween = create_tween()
	scale_tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.1).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	scale_tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)

	# Auto-destruir após animação
	await get_tree().create_timer(duration).timeout
	queue_free()

func setup(value: String, color: Color = Color.WHITE, size: int = 32):
	text = value
	modulate = color

	# Criar LabelSettings dinamicamente
	var settings = LabelSettings.new()
	settings.font_size = size
	settings.outline_size = 4
	settings.outline_color = Color.BLACK
	label_settings = settings
