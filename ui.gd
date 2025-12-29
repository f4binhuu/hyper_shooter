extends CanvasLayer

@onready var power_label = $PowerLabel
@onready var boost_label = $BoostLabel
@onready var player = get_parent().get_node("Player")

func _process(delta):
	if player and "power" in player:
		power_label.text = "Power: " + str(player.power)

		if "boost_charge" in player:
			var charge_percent = int(player.boost_charge)
			boost_label.text = "BOOST: " + str(charge_percent) + "%"

			# Mudar cor baseado na carga
			if player.boost_charge >= 100.0:
				boost_label.modulate = Color(0.3, 1.0, 0.3)  # Verde quando pronto
			elif player.boost_charge >= 50.0:
				boost_label.modulate = Color(1.0, 1.0, 0.3)  # Amarelo
			else:
				boost_label.modulate = Color(1.0, 0.5, 0.5)  # Vermelho
