extends CanvasLayer

signal upgrade_selected(config: UpgradeConfig)

@onready var cards_container = $CenterContainer/VBoxContainer/CardsContainer
@onready var center_container = $CenterContainer

var card_scene = preload("res://ui/upgrade_card.tscn")

func _ready():
	# Animação de entrada
	center_container.modulate.a = 0.0
	center_container.scale = Vector2(0.8, 0.8)

	var tween = create_tween().set_parallel(true)
	tween.tween_property(center_container, "modulate:a", 1.0, 0.3)
	tween.tween_property(center_container, "scale", Vector2(1.0, 1.0), 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func show_upgrades(upgrade_configs: Array, player_upgrade_levels: Dictionary):
	# Limpar cards anteriores
	for child in cards_container.get_children():
		child.queue_free()

	# Criar card para cada upgrade
	for config in upgrade_configs:
		var card = card_scene.instantiate()
		cards_container.add_child(card)

		# Calcular nível atual do upgrade
		var upgrade_name = UpgradeConfig.UpgradeType.keys()[config.upgrade_type]
		var current_level = 1
		if player_upgrade_levels.has(upgrade_name):
			current_level = player_upgrade_levels[upgrade_name] + 1

		card.setup(config, current_level)
		card.card_clicked.connect(_on_card_clicked)

func _on_card_clicked(config: UpgradeConfig):
	# Animação de saída
	var tween = create_tween().set_parallel(true)
	tween.tween_property(center_container, "modulate:a", 0.0, 0.2)
	tween.tween_property(center_container, "scale", Vector2(0.8, 0.8), 0.2)

	await tween.finished

	# Emitir sinal e destruir UI
	upgrade_selected.emit(config)
	queue_free()
