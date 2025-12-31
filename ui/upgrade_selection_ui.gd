extends CanvasLayer

signal upgrade_selected(config: UpgradeConfig)

@onready var cards_container = $CenterContainer/VBoxContainer/CardsContainer
@onready var center_container = $CenterContainer

var card_scene = preload("res://ui/upgrade_card.tscn")
var audio_config: AudioConfig
var highest_rarity: int = 0  # Armazena a raridade mais alta dos upgrades

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

	# Detectar a raridade mais alta dos upgrades apresentados
	highest_rarity = UpgradeConfig.UpgradeRarity.COMMON
	for config in upgrade_configs:
		if config.rarity > highest_rarity:
			highest_rarity = config.rarity

	# Tocar som apropriado baseado na raridade mais alta
	if audio_config:
		var sound_type: AudioConfig.SoundType
		match highest_rarity:
			UpgradeConfig.UpgradeRarity.COMMON:
				sound_type = AudioConfig.SoundType.UPGRADE_COMMON
			UpgradeConfig.UpgradeRarity.UNCOMMON:
				sound_type = AudioConfig.SoundType.UPGRADE_UNCOMMON
			UpgradeConfig.UpgradeRarity.RARE:
				sound_type = AudioConfig.SoundType.UPGRADE_RARE
			UpgradeConfig.UpgradeRarity.EPIC:
				sound_type = AudioConfig.SoundType.UPGRADE_EPIC
			_:
				sound_type = AudioConfig.SoundType.UPGRADE_COMMON

		AudioHelper.play_sound(
			audio_config.get_sound(sound_type),
			audio_config.get_volume(sound_type),
			self
		)

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
