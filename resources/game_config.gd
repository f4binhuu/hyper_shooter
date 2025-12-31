extends Resource
class_name GameConfig

## Configuração global do jogo

@export_group("Upgrade System")
@export var upgrade_point_threshold: int = 1000  ## Pontos necessários para o primeiro upgrade
@export_range(1.2, 3.0, 0.1) var upgrade_scaling_multiplier: float = 2.0  ## Multiplicador de scaling (1000 → 2000 → 4000...)
@export var upgrades_per_selection: int = 3  ## Quantos upgrades oferecer por vez

@export_group("Multiplier Spawning")
@export_range(3.0, 20.0, 0.5) var multiplier_spawn_interval: float = 7.0  ## Intervalo entre spawns de multiplicadores

@export_group("Enemy Balancing")
@export_range(0.5, 2.0, 0.1) var enemy_health_multiplier: float = 1.0  ## Multiplicador global de vida dos inimigos
@export_range(0.5, 2.0, 0.1) var enemy_speed_multiplier: float = 1.0  ## Multiplicador global de velocidade
@export_range(0.5, 2.0, 0.1) var enemy_points_multiplier: float = 1.0  ## Multiplicador global de pontos

@export_group("Wave System")
@export var loop_waves: bool = true  ## Repetir waves quando acabar

@export_group("Player Health")
@export_range(1, 10) var player_max_health: int = 3  ## Vida máxima do player
@export_range(0.5, 3.0, 0.1) var player_invincibility_duration: float = 1.0  ## Duração dos iframes após dano (segundos)
@export_range(1, 5) var enemy_contact_damage: int = 1  ## Dano que inimigos causam ao colidir com player
