extends Label

var player
var game

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")

	# Buscar o nó Game (é o pai do UI)
	game = get_node("../..")

	# Conectar aos sinais de wave
	if game and game.has_signal("wave_started"):
		game.wave_started.connect(_on_wave_started)
		print("UI conectado aos sinais de wave!")
	else:
		print("ERRO: Não conseguiu conectar ao Game node")

	# Conectar ao sinal de combo
	if player and player.has_signal("combo_changed"):
		player.combo_changed.connect(_on_combo_changed)

	# Conectar ao sinal de health
	if player and player.has_signal("health_changed"):
		player.health_changed.connect(_on_health_changed)

	# Conectar aos sinais de XP e Level
	if player and player.has_signal("xp_gained"):
		player.xp_gained.connect(_on_xp_gained)
	if player and player.has_signal("level_up"):
		player.level_up.connect(_on_level_up)

func _process(delta: float) -> void:
	if player and is_instance_valid(player):
		if "power" in player and "shockwave_charge" in player:
			var charge_percent = int(player.shockwave_charge)

			# Adicionar informação de wave se o game existir
			var wave_text = ""
			if game and game.current_wave:
				wave_text = "WAVE " + str(game.current_wave.wave_number) + "\n"

			# HP agora é exibido na barra de vida do player, não precisa mais mostrar aqui

			# Adicionar indicador de shield
			var shield_text = ""
			if "has_shield" in player and player.has_shield:
				shield_text = " [SHIELD]"

			# Adicionar Level e XP 
			var level_text = ""
			if "current_level" in player and "current_xp" in player and "xp_to_next_level" in player:
				level_text = "LEVEL " + str(player.current_level) + " | XP: " + str(player.current_xp) + "/" + str(player.xp_to_next_level) + "\n"

			# Adicionar combo
			var combo_text = ""
			if "combo_count" in player and player.combo_count > 1:
				var multiplier = player.get_combo_multiplier()
				combo_text = "\nCOMBO x" + str(player.combo_count) + " (" + str(multiplier) + "x)"

			text = wave_text + level_text + "SCORE: " + str(player.power) + shield_text + "\nSHOCKWAVE: " + str(charge_percent) + "%" + combo_text

			# Mudar cor baseado no combo, shield e carga
			if "combo_count" in player and player.combo_count > 1:
				label_settings.font_color = Color(1.0, 0.6, 0.0)  # Laranja quando combo ativo
			elif "has_shield" in player and player.has_shield:
				label_settings.font_color = Color(0.3, 0.8, 1.0)  # Azul quando tem shield
			elif player.shockwave_charge >= 100.0:
				label_settings.font_color = Color(0.3, 1.0, 0.3)  # Verde quando pronto
			elif player.shockwave_charge >= 50.0:
				label_settings.font_color = Color(1.0, 1.0, 0.3)  # Amarelo
			else:
				label_settings.font_color = Color(1.0, 1.0, 1.0)  # Branco normal

func _on_wave_started(wave_number: int):
	# Feedback visual quando wave começa
	print("UI: Wave ", wave_number, " iniciada!")

func _on_combo_changed(count: int):
	if count > 1:
		# Animação de bounce quando combo aumenta
		var tween = create_tween()
		tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.1)
		tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)

func _on_health_changed(current: int, maximum: int):
	# Feedback visual quando toma dano
	if current < maximum:
		# Flash vermelho
		var tween = create_tween()
		tween.tween_property(self, "modulate", Color(1, 0.3, 0.3), 0.1)
		tween.tween_property(self, "modulate", Color(1, 1, 1), 0.2)

func _on_xp_gained(amount: int, current: int, required: int):
	# Pequeno feedback quando ganha XP
	pass  # Pode adicionar animação de barra de XP aqui

func _on_level_up(new_level: int):
	# Feedback visual GRANDE quando sobe de level
	print("UI: LEVEL UP! Level ", new_level)

	# Animação de explosão
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.5, 1.5), 0.2)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.3)

	# Flash dourado
	tween = create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 0), 0.2)
	tween.tween_property(self, "modulate", Color(1, 1, 1), 0.3)
