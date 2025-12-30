extends Resource
class_name WaveConfig

## Configuração de uma Wave de inimigos
## Crie arquivos .tres no Godot para cada wave

@export_group("Wave Info")
@export var wave_number: int = 1
@export_multiline var wave_description: String = "Wave inicial"

@export_group("Spawn Settings")
@export_range(0.1, 10.0, 0.1) var spawn_interval: float = 1.0
@export_range(1, 10) var enemies_per_spawn: int = 2

@export_group("Enemy Types")
## Chances de spawn (soma deve ser ~1.0)
@export_range(0.0, 1.0, 0.05) var enemy_lvl_1_chance: float = 1.0
@export_range(0.0, 1.0, 0.05) var enemy_lvl_2_chance: float = 0.0
@export_range(0.0, 1.0, 0.05) var enemy_lvl_3_chance: float = 0.0

@export_group("Enemy Stats (Legacy - usado para spawn manual)")
@export_range(1, 100) var enemy_health: int = 1
@export_range(10.0, 500.0, 10.0) var enemy_speed: float = 50.0
@export_range(1, 100) var enemy_points: int = 10

@export_group("Wave Progression")
@export var wave_duration: float = 30.0  # Duração em segundos (0 = infinita)
@export var enemies_to_kill: int = 0  # Inimigos para avançar (0 = usa duração)
