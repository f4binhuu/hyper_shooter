extends Resource
class_name EnemyConfig

## Configuração de arquétipo de inimigo com sistema de níveis
## Cada tier representa um arquétipo (Swarm, Bruiser, Elite)
## Cada nível escala stats baseado na wave atual

enum EnemyTier {
	SWARM,    # Tier 1: Fraco, rápido, numeroso
	BRUISER,  # Tier 2: Balanceado, HP médio
	ELITE     # Tier 3: Tanque, HP alto, lento
}

@export_group("Tier Info")
@export var tier: EnemyTier = EnemyTier.SWARM
@export var tier_name: String = "Swarm"
@export_multiline var description: String = "Inimigos fracos mas rápidos"

@export_group("Visual")
@export var sprite: Texture2D  ## Sprite do inimigo
@export var base_scale: float = 0.4  ## Escala visual base
@export var base_color: Color = Color.WHITE  ## Cor base (pode modular por nível)

@export_group("Base Stats (Level 1)")
@export_range(1, 50) var base_health: int = 1  ## Vida inicial
@export_range(50.0, 400.0, 10.0) var base_speed: float = 220.0  ## Velocidade inicial
@export_range(1, 50) var base_xp: int = 1  ## XP que dá ao morrer
@export_range(5, 200) var base_points: int = 10  ## Pontos que dá ao morrer

@export_group("Scaling Per Level")
## Quanto cada stat aumenta por nível (1→2→3→4→5)
@export var health_per_level: float = 0.5  ## +0.5 HP por nível
@export var speed_per_level: float = 20.0  ## +20 speed por nível
@export var xp_per_level: float = 0.5  ## +0.5 XP por nível (arredondado)
@export var points_per_level: int = 5  ## +5 pontos por nível

@export_group("Archetype Behavior")
@export_range(0.1, 2.0, 0.1) var knockback_resistance: float = 1.0  ## Resistência a knockback (0.5 = metade)
@export var can_dodge: bool = false  ## Futuro: Capacidade de desviar de balas
@export var spawns_on_death: int = 0  ## Futuro: Quantos inimigos menores spawnam ao morrer

## Calcula stats finais baseado no nível do inimigo
func get_stats_at_level(level: int) -> Dictionary:
	var level_modifier = level - 1  # Level 1 = 0 modifier

	return {
		"health": int(base_health + (health_per_level * level_modifier)),
		"speed": base_speed + (speed_per_level * level_modifier),
		"xp": int(base_xp + (xp_per_level * level_modifier)),
		"points": base_points + (points_per_level * level_modifier)
	}

## Retorna cor modulada baseada no nível (visual feedback)
func get_color_for_level(level: int) -> Color:
	match tier:
		EnemyTier.SWARM:
			# Verde claro → Verde escuro
			return base_color.lerp(Color(0.0, 0.8, 0.3), (level - 1) / 4.0)
		EnemyTier.BRUISER:
			# Azul claro → Azul escuro
			return base_color.lerp(Color(0.3, 0.5, 1.0), (level - 1) / 4.0)
		EnemyTier.ELITE:
			# Vermelho claro → Vermelho intenso
			return base_color.lerp(Color(1.0, 0.2, 0.2), (level - 1) / 4.0)
		_:
			return base_color

## Retorna nome exibível do inimigo (Tier + Nível)
func get_display_name(level: int) -> String:
	if level == 1:
		return tier_name
	else:
		return tier_name + " Lv." + str(level)

## Calcula knockback final aplicado (resistência do tier)
func apply_knockback_resistance(base_knockback: float) -> float:
	return base_knockback * knockback_resistance
