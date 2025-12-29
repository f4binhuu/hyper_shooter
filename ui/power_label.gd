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

func _process(delta: float) -> void:
	if player and is_instance_valid(player):
		if "power" in player and "shockwave_charge" in player:
			var charge_percent = int(player.shockwave_charge)

			# Adicionar informação de wave se o game existir
			var wave_text = ""
			if game and game.current_wave:
				wave_text = "WAVE " + str(game.current_wave.wave_number) + "\n"

			# Adicionar indicador de shield
			var shield_text = ""
			if "has_shield" in player and player.has_shield:
				shield_text = " [SHIELD]"

			text = wave_text + "Power: " + str(player.power) + shield_text + "\nSHOCKWAVE: " + str(charge_percent) + "%"

			# Mudar cor baseado no shield e carga
			if "has_shield" in player and player.has_shield:
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
