extends Node
class_name WaveGenerator

## Gerador procedural de waves com progressão infinita
## Mantém arquitetura preparada para boss waves no futuro

# Fórmulas de balanceamento
const BASE_SPAWN_INTERVAL = 1.5  # Segundos entre spawns (wave 1)
const MIN_SPAWN_INTERVAL = 0.3   # Intervalo mínimo (waves avançadas)
const SPAWN_DECAY_RATE = 0.92    # Taxa de aceleração (0.92 = ~8% mais rápido por wave)

const BASE_DURATION = 20.0       # Duração inicial (segundos)
const DURATION_INCREMENT = 2.0   # +2s por wave
const MAX_DURATION = 45.0        # Cap de duração

const MIN_ENEMIES_PER_SPAWN = 1
const MAX_ENEMIES_PER_SPAWN = 6  # Cap de inimigos simultâneos

# Curvas de composição de inimigos (valores ajustados empiricamente)
const LVL1_INITIAL = 1.0         # Wave 1: 100% lvl1
const LVL1_DECAY = 0.15          # Decai ~15% por wave
const LVL2_START_WAVE = 2        # Lvl2 surge na wave 2
const LVL3_START_WAVE = 3        # Lvl3 surge na wave 3

## Gera uma wave proceduralmente baseada no número da wave
static func generate_wave(wave_number: int) -> WaveConfig:
	var wave = WaveConfig.new()

	# Informação básica
	wave.wave_number = wave_number
	wave.wave_description = get_wave_description(wave_number)

	# Spawn settings
	wave.spawn_interval = calculate_spawn_interval(wave_number)
	wave.enemies_per_spawn = calculate_enemies_per_spawn(wave_number)

	# Composição de inimigos (lvl1, lvl2, lvl3)
	var composition = calculate_enemy_composition(wave_number)
	wave.enemy_lvl_1_chance = composition[0]
	wave.enemy_lvl_2_chance = composition[1]
	wave.enemy_lvl_3_chance = composition[2]

	# Progressão da wave
	wave.wave_duration = calculate_wave_duration(wave_number)
	wave.enemies_to_kill = 0  # Sempre usa time-based (não kill-based)

	# Legacy stats (não usados ativamente, mas mantidos por compatibilidade)
	wave.enemy_health = 1
	wave.enemy_speed = 50.0
	wave.enemy_points = 10

	return wave

## Calcula intervalo entre spawns (decai exponencialmente)
static func calculate_spawn_interval(wave_number: int) -> float:
	var interval = BASE_SPAWN_INTERVAL * pow(SPAWN_DECAY_RATE, wave_number - 1)
	return max(MIN_SPAWN_INTERVAL, interval)

## Calcula quantos inimigos spawnam por vez
## Aumenta gradualmente: 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6...
static func calculate_enemies_per_spawn(wave_number: int) -> int:
	var count = MIN_ENEMIES_PER_SPAWN + int(floor(wave_number / 2.0))
	return min(MAX_ENEMIES_PER_SPAWN, count)

## Calcula duração da wave em segundos
static func calculate_wave_duration(wave_number: int) -> float:
	var duration = BASE_DURATION + (DURATION_INCREMENT * (wave_number - 1))
	return min(MAX_DURATION, duration)

## Calcula composição de tipos de inimigos [lvl1, lvl2, lvl3]
## Usa curvas sigmoides para transição suave entre tipos
static func calculate_enemy_composition(wave_number: int) -> Array:
	var lvl1_chance = 0.0
	var lvl2_chance = 0.0
	var lvl3_chance = 0.0

	# Level 1: Decai de 100% para ~10% em 10 waves
	if wave_number == 1:
		lvl1_chance = 1.0
	else:
		# Decaimento exponencial suave
		lvl1_chance = max(0.1, 1.0 - (LVL1_DECAY * (wave_number - 1)))

	# Level 2: Surge na wave 2, atinge pico ~50% nas waves 5-8
	if wave_number >= LVL2_START_WAVE:
		# Curva sigmoide centrada na wave 5
		var x = (wave_number - 5.0) / 3.0
		lvl2_chance = 0.5 / (1.0 + exp(-x))

	# Level 3: Surge na wave 3, cresce até ~70% nas waves 15+
	if wave_number >= LVL3_START_WAVE:
		# Curva logística crescente
		var x = (wave_number - 8.0) / 4.0
		lvl3_chance = 0.7 / (1.0 + exp(-x))

	# Normalizar para soma = 1.0 (distribuição probabilística válida)
	var total = lvl1_chance + lvl2_chance + lvl3_chance
	if total > 0:
		lvl1_chance /= total
		lvl2_chance /= total
		lvl3_chance /= total
	else:
		# Fallback (não deve acontecer)
		lvl1_chance = 1.0

	return [lvl1_chance, lvl2_chance, lvl3_chance]

## Retorna descrição temática para a wave
static func get_wave_description(wave_number: int) -> String:
	match wave_number:
		1: return "Primeiros Invasores"
		2: return "Eles Estão Aprendendo"
		3: return "A Invasão Intensifica"
		4: return "Reforços Chegaram"
		5: return "Horda Implacável"
		_:
			# Waves 6+: Descrições genéricas progressivas
			if wave_number % 5 == 0:
				# TODO FUTURO: Boss waves terão descrições especiais
				return "Onda Crítica #" + str(wave_number)
			elif wave_number >= 20:
				return "Apocalipse Infinito #" + str(wave_number)
			elif wave_number >= 15:
				return "Sobrevivência Extrema #" + str(wave_number)
			elif wave_number >= 10:
				return "Caos Total #" + str(wave_number)
			else:
				return "Onda de Ataque #" + str(wave_number)

## Determina se esta wave deveria ser um boss fight
## TODO FUTURO: Implementar quando boss system estiver pronto
static func should_spawn_boss(wave_number: int, boss_frequency: int = 5) -> bool:
	# Boss a cada N waves (ex: 5, 10, 15, 20...)
	return wave_number > 0 and wave_number % boss_frequency == 0

## Calcula nível dos inimigos baseado na wave atual
## Enemies evoluem a cada 3 waves: 1→2→3→4→5 (cap)
static func calculate_enemy_level(wave_number: int) -> int:
	# Wave 1-2: Level 1
	# Wave 3-5: Level 2
	# Wave 6-8: Level 3
	# Wave 9-11: Level 4
	# Wave 12+: Level 5
	return min(5, 1 + int(floor((wave_number - 1) / 3.0)))

## TODO FUTURO: Criar boss wave config
## static func generate_boss_wave(wave_number: int, boss_config: BossConfig) -> WaveConfig:
##     var wave = WaveConfig.new()
##     wave.wave_number = wave_number
##     wave.wave_description = "BOSS: " + boss_config.boss_name
##     # ... configuração específica de boss
##     return wave
