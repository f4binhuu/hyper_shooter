class_name UpgradeConfig
extends Resource

enum UpgradeType {
	FIRE_RATE,      # Cadência - reduz fire_rate
	DAMAGE,         # Dano - aumenta dano dos tiros
	MULTI_SHOT,     # Multi-Tiro - adiciona projéteis extras
	PIERCE,         # Perfuração - tiros atravessam inimigos
	SPEED,          # Velocidade - movimento mais rápido (não usado ainda)
	SHIELD_BOOST,   # Escudo - aumenta chance de spawnar shields
	SHOCKWAVE_BOOST,# Shockwave - aumenta dano/raio do shockwave
	HEALTH_REGEN    # Regeneração de vida
}

enum UpgradeRarity {
	COMMON,      # Aparece desde o início
	UNCOMMON,    # Aparece a partir do level 5
	RARE,        # Aparece a partir do level 10
	EPIC         # Aparece a partir do level 15
}

@export var upgrade_type: UpgradeType = UpgradeType.FIRE_RATE
@export var display_name: String = "Cadência"
@export_multiline var description: String = "Aumenta a velocidade de disparo"
@export var icon_color: Color = Color(1, 1, 0, 1)
@export var rarity: UpgradeRarity = UpgradeRarity.COMMON

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
		UpgradeType.HEALTH_REGEN:
			return description + "\nRegenera: +" + str(value) + " HP/s"

	return description

func get_min_level_required() -> int:
	"""Retorna o nível mínimo necessário para este upgrade aparecer"""
	match rarity:
		UpgradeRarity.COMMON:
			return 1
		UpgradeRarity.UNCOMMON:
			return 5
		UpgradeRarity.RARE:
			return 10
		UpgradeRarity.EPIC:
			return 15
	return 1

func get_weight_at_player_level(player_level: int, current_upgrade_level: int) -> float:
	"""Calcula o peso/probabilidade deste upgrade aparecer baseado no nível do player"""
	# Não pode aparecer se player ainda não atingiu nível mínimo
	if player_level < get_min_level_required():
		return 0.0

	# Se já está no nível máximo, não aparece
	if max_level > 0 and current_upgrade_level >= max_level:
		return 0.0

	# Peso base por raridade
	var base_weight: float = 1.0
	match rarity:
		UpgradeRarity.COMMON:
			base_weight = 10.0  # Muito comum
		UpgradeRarity.UNCOMMON:
			base_weight = 6.0   # Razoavelmente comum
		UpgradeRarity.RARE:
			base_weight = 3.0   # Raro
		UpgradeRarity.EPIC:
			base_weight = 1.0   # Muito raro

	# Reduz peso se já tem muitos níveis deste upgrade
	var level_penalty = 1.0 - (current_upgrade_level * 0.1)
	level_penalty = max(level_penalty, 0.3)  # Mínimo 30% do peso original

	return base_weight * level_penalty
