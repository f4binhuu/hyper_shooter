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

@export_group("Wave System (Procedural)")
## Sistema procedural gera waves infinitas automaticamente
@export_range(0.5, 2.0, 0.1) var difficulty_multiplier: float = 1.0  ## Multiplica curva de dificuldade global
@export_range(0.2, 1.0, 0.05) var max_spawn_rate: float = 0.3  ## Intervalo mínimo entre spawns (segundos)
@export_range(4, 10) var max_enemies_per_spawn: int = 6  ## Máximo de inimigos por batch

@export_group("Boss Waves (Futuro)")
## Sistema de boss ainda não implementado - configuração preparada
@export_range(3, 10) var boss_every_n_waves: int = 5  ## Boss surge a cada N waves (ex: 5, 10, 15...)
@export_range(3.0, 10.0, 0.5) var boss_prep_time: float = 5.0  ## Segundos de preparação antes do boss aparecer

@export_group("Player Health")
@export_range(50, 200, 10) var player_max_health: int = 100  ## Vida máxima do player (HP numérico)
@export_range(0.5, 3.0, 0.1) var player_invincibility_duration: float = 1.0  ## Duração dos iframes após dano (segundos)
@export_range(5, 50, 5) var enemy_contact_damage: int = 20  ## Dano que inimigos causam ao colidir com player
@export_range(5, 50, 5) var enemy_escape_damage: int = 15  ## Dano quando inimigo escapa pela parte inferior
