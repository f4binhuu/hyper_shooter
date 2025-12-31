# PLACEHOLDER - Boss System (Futuro)
#
# Este arquivo está preparado para quando o sistema de bosses for implementado.
# Atualmente comentado para não poluir autocompletion.
#
# Para ativar: Descomente as linhas abaixo e implemente boss logic em game.gd
#
# extends Resource
# class_name BossConfig
#
# @export_group("Boss Info")
# @export var boss_name: String = "???"
# @export_multiline var boss_description: String = "Um boss poderoso..."
# @export var boss_tier: int = 1  ## Tier do boss (1, 2, 3...)
#
# @export_group("Boss Stats")
# @export var boss_health: int = 1000  ## Vida total do boss
# @export var boss_speed: float = 100.0  ## Velocidade de movimento
# @export var boss_damage: int = 2  ## Dano de contato
# @export var boss_points_reward: int = 500  ## Pontos ao derrotar
#
# @export_group("Boss Scene")
# @export var boss_scene: PackedScene  ## Cena do boss (node customizado)
#
# @export_group("Attack Patterns")
# ## Array de padrões de ataque (ainda não definido)
# ## Pode incluir: ProjectilePattern, DashAttack, SummonMinions, etc
# # @export var attack_patterns: Array[AttackPattern] = []
#
# @export_group("Rewards")
# @export var guaranteed_upgrades: int = 2  ## Upgrades garantidos ao derrotar
# @export var bonus_xp: int = 100  ## XP extra
# @export var special_reward_chance: float = 0.5  ## Chance de drop especial
#
# ## Boss-specific abilities
# @export_group("Special Abilities")
# @export var can_summon_minions: bool = false
# @export var has_shield_phase: bool = false
# @export var enrage_at_health_percent: float = 0.3  ## Enrage quando chega em 30% HP
#
# ## Hooks para customização
# func get_health_at_tier(tier: int) -> int:
#     """Escala vida do boss baseado no tier"""
#     return boss_health * (1 + (tier - 1) * 0.5)  # +50% por tier
#
# func get_attack_speed_multiplier(current_health_percent: float) -> float:
#     """Boss fica mais rápido com menos HP"""
#     if current_health_percent < enrage_at_health_percent:
#         return 1.5  # 50% mais rápido quando enraged
#     return 1.0
