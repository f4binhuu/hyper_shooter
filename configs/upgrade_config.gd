class_name UpgradeConfig
extends Resource

enum UpgradeType {
	FIRE_RATE,      # Cadência - reduz fire_rate
	DAMAGE,         # Dano - aumenta dano dos tiros
	MULTI_SHOT,     # Multi-Tiro - adiciona projéteis extras
	PIERCE,         # Perfuração - tiros atravessam inimigos
	SPEED,          # Velocidade - movimento mais rápido (não usado ainda)
	SHIELD_BOOST,   # Escudo - aumenta chance de spawnar shields
	SHOCKWAVE_BOOST # Shockwave - aumenta dano/raio do shockwave
}

@export var upgrade_type: UpgradeType = UpgradeType.FIRE_RATE
@export var display_name: String = "Cadência"
@export_multiline var description: String = "Aumenta a velocidade de disparo"
@export var icon_color: Color = Color(1, 1, 0, 1)

# Valores base e escala
@export_group("Scaling Values")
@export var base_value: float = 0.05  # Valor inicial
@export var increment_per_level: float = 0.03  # Quanto aumenta por nível
@export var max_level: int = 10  # Máximo de stacks (-1 = infinito)

# Para upgrades de contagem (multi-shot, pierce)
@export var is_count_based: bool = false  # Se true, usa valores inteiros

func get_value_at_level(level: int) -> float:
	"""Calcula o valor do upgrade no nível especificado"""
	var value = base_value + (increment_per_level * (level - 1))

	if is_count_based:
		return float(int(value))

	return value

func get_description_at_level(level: int) -> String:
	"""Retorna descrição com valor atual"""
	var value = get_value_at_level(level)

	match upgrade_type:
		UpgradeType.FIRE_RATE:
			return description + "\nCadência: -" + str(value) + "s"
		UpgradeType.DAMAGE:
			return description + "\nDano extra: +" + str(int(value))
		UpgradeType.MULTI_SHOT:
			return description + "\nProjéteis extras: +" + str(int(value))
		UpgradeType.PIERCE:
			return description + "\nInimigos atravessados: " + str(int(value))
		UpgradeType.SHIELD_BOOST:
			return description + "\nChance extra: +" + str(int(value * 100)) + "%"
		UpgradeType.SHOCKWAVE_BOOST:
			return description + "\nDano extra: +" + str(int(value))

	return description
