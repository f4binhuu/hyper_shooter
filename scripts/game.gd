extends Node2D

@onready var enemy_scene = preload("res://scenes/enemy.tscn")  # Scene base universal
@onready var multiplier_scene = preload("res://scenes/multiplier.tscn")
@onready var upgrade_ui_scene = preload("res://ui/upgrade_selection_ui.tscn")
@onready var game_over_screen_scene = preload("res://ui/game_over_screen.tscn")

# Enemy configs (Tier system)
@onready var enemy_configs = [
	preload("res://resources/enemies/enemy_config_swarm.tres"),    # Tier 1
	preload("res://resources/enemies/enemy_config_bruiser.tres"),  # Tier 2
	preload("res://resources/enemies/enemy_config_elite.tres")     # Tier 3
]

@export var game_config: GameConfig
@export var audio_config: AudioConfig
@export var multipliers: Array[MultiplierConfig] = []
@export var upgrades: Array[UpgradeConfig] = []

# Waves geradas proceduralmente (não mais @export)
var waves: Array[WaveConfig] = []
var current_wave_index: int = 0
var current_wave: WaveConfig
var is_boss_wave: bool = false  # Flag para wave atual (futuro: boss fights)
var wave_timer: float = 0.0
var spawn_timer: float = 0.0
var multiplier_timer: float = 0.0
var enemies_killed_this_wave: int = 0
var next_upgrade_at: int = 0
var last_power_check: int = 0
var is_transitioning_wave: bool = false
var is_game_over: bool = false
var max_combo_reached: int = 0
var music_player: AudioStreamPlayer

signal wave_started(wave_number: int)
signal wave_completed(wave_number: int)


func _ready() -> void:
	if not game_config:
		push_error("ERRO: GameConfig não configurado! Adicione um game_config.tres no Inspector.")
		return

	# Carregar audio_config automaticamente se não estiver configurado
	if not audio_config:
		audio_config = load("res://resources/audio_config.tres")
		if audio_config:
			print("AudioConfig carregado automaticamente")

	next_upgrade_at = game_config.upgrade_point_threshold

	# Conectar ao sinal de morte do player e configurar audio
	var player = get_tree().get_first_node_in_group("player")
	if player:
		# Passar audio_config para o player
		if audio_config:
			player.audio_config = audio_config

		if player.has_signal("player_died"):
			player.player_died.connect(on_player_died)
			print("Game conectado ao sinal de morte do player")

	# Conectar ao combo do player para trackear max combo
	if player and player.has_signal("combo_changed"):
		player.combo_changed.connect(_on_combo_changed)

	# Conectar ao level_up do player
	if player and player.has_signal("level_up"):
		player.level_up.connect(on_player_level_up)
		print("Game conectado ao sinal de level_up do player")

	# Iniciar música de fundo
	if audio_config:
		var music_stream = audio_config.get_sound(AudioConfig.SoundType.BACKGROUND_MUSIC)
		if music_stream:
			music_player = AudioStreamPlayer.new()
			music_player.stream = music_stream
			music_player.volume_db = audio_config.get_volume(AudioConfig.SoundType.BACKGROUND_MUSIC)
			music_player.autoplay = false
			music_player.process_mode = Node.PROCESS_MODE_ALWAYS  # Continua tocando mesmo quando o jogo pausa
			add_child(music_player)

			# Configurar loop para MP3
			if music_stream is AudioStreamMP3:
				music_stream.loop = true

			music_player.play()
			print("Background music iniciada")

	# Iniciar primeira wave (será gerada proceduralmente)
	start_wave(0)

func _process(delta):
	if not current_wave or is_game_over:
		return

	# Timer de spawn de inimigos
	spawn_timer += delta

	if spawn_timer >= current_wave.spawn_interval:
		spawn_enemies()
		spawn_timer = 0.0

	# Timer de spawn de multiplicadores
	multiplier_timer += delta

	if multiplier_timer >= game_config.multiplier_spawn_interval:
		spawn_multiplier()
		multiplier_timer = 0.0

	# Timer de duração da wave (se configurado)
	if current_wave.wave_duration > 0:
		wave_timer += delta
		if wave_timer >= current_wave.wave_duration:
			complete_wave()

	# check_upgrade_threshold()

## Obtém wave existente ou gera uma nova proceduralmente
## Preparado para suporte a boss waves no futuro
func get_or_generate_wave(wave_index: int) -> WaveConfig:
	# Se wave já foi gerada anteriormente, retornar do cache
	if wave_index < waves.size():
		return waves[wave_index]

	var wave_number = wave_index + 1

	# TODO FUTURO: Inserir lógica de boss waves aqui
	# if game_config and WaveGenerator.should_spawn_boss(wave_number, game_config.boss_every_n_waves):
	#     is_boss_wave = true
	#     return create_boss_wave(wave_number)

	# Wave normal - gerar proceduralmente
	is_boss_wave = false
	var new_wave = WaveGenerator.generate_wave(wave_number)
	waves.append(new_wave)

	print("Wave ", wave_number, " gerada: spawn_interval=", new_wave.spawn_interval,
		  "s, enemies/spawn=", new_wave.enemies_per_spawn,
		  ", lvl1=", snappedf(new_wave.enemy_lvl_1_chance * 100, 0.1), "%",
		  ", lvl2=", snappedf(new_wave.enemy_lvl_2_chance * 100, 0.1), "%",
		  ", lvl3=", snappedf(new_wave.enemy_lvl_3_chance * 100, 0.1), "%")

	return new_wave

func start_wave(wave_index: int):
	current_wave_index = wave_index
	current_wave = get_or_generate_wave(wave_index)
	wave_timer = 0.0
	spawn_timer = 0.0
	enemies_killed_this_wave = 0
	is_transitioning_wave = false  # Reset flag ao iniciar nova wave

	# TODO FUTURO: Lógica específica para boss waves
	# if is_boss_wave:
	#     prepare_boss_battle()
	#     return

	wave_started.emit(current_wave.wave_number)
	print("=== WAVE ", current_wave.wave_number, " INICIADA ===")
	print(current_wave.wave_description)

func complete_wave():
	# Prevenir múltiplas chamadas
	if is_transitioning_wave:
		return

	is_transitioning_wave = true
	wave_completed.emit(current_wave.wave_number)
	print("=== WAVE ", current_wave.wave_number, " COMPLETADA ===")

	# TODO FUTURO: Recompensas extras para boss waves
	# if is_boss_wave:
	#     give_boss_rewards()
	#     show_boss_victory_screen()

	# Pequeno delay antes da próxima wave
	await get_tree().create_timer(2.0).timeout
	start_wave(current_wave_index + 1)

func on_enemy_killed():
	enemies_killed_this_wave += 1

	# Se configurado para avançar por kills
	if current_wave.enemies_to_kill > 0:
		if enemies_killed_this_wave >= current_wave.enemies_to_kill:
			complete_wave()

func spawn_enemies():
	# Calcular nível dos inimigos baseado na wave atual
	var enemy_level = WaveGenerator.calculate_enemy_level(current_wave.wave_number)

	# Spawnar múltiplos inimigos de uma vez
	for i in range(current_wave.enemies_per_spawn):
		# Escolher tier baseado nas chances da wave
		var enemy_tier_index = choose_enemy_tier()
		var enemy_config = enemy_configs[enemy_tier_index]

		# Instanciar enemy base e configurar
		var enemy = enemy_scene.instantiate()
		enemy.enemy_config = enemy_config
		enemy.enemy_level = enemy_level

		# Passar audio_config para o inimigo
		if audio_config:
			enemy.audio_config = audio_config

		var spawn_x = randf_range(50, get_viewport_rect().size.x - 50)
		enemy.position = Vector2(spawn_x, -50)

		add_child(enemy)

		# Conectar sinal de morte do inimigo
		enemy.tree_exited.connect(on_enemy_killed)

		# Pequeno delay entre cada spawn
		await get_tree().create_timer(0.1).timeout

## Escolhe tier do inimigo (0=Swarm, 1=Bruiser, 2=Elite) baseado nas chances da wave
func choose_enemy_tier() -> int:
	# Weighted random selection baseado nas chances da wave
	var total_chance = current_wave.enemy_lvl_1_chance + current_wave.enemy_lvl_2_chance + current_wave.enemy_lvl_3_chance
	var rand_value = randf() * total_chance

	if rand_value < current_wave.enemy_lvl_1_chance:
		return 0  # Swarm (Tier 1)
	elif rand_value < current_wave.enemy_lvl_1_chance + current_wave.enemy_lvl_2_chance:
		return 1  # Bruiser (Tier 2)
	else:
		return 2  # Elite (Tier 3)

func spawn_multiplier():
	if multipliers.size() == 0:
		return

	# Escolher multiplicador baseado em rarity (weighted random)
	var selected_mult = choose_weighted_multiplier()
	if not selected_mult:
		return

	var mult = multiplier_scene.instantiate()
	mult.config = selected_mult

	# Spawn em posição X aleatória
	var spawn_x = randf_range(50, get_viewport_rect().size.x - 50)
	mult.position = Vector2(spawn_x, -50)

	add_child(mult)
	print("Multiplicador spawned: ", selected_mult.display_text)

func choose_weighted_multiplier() -> MultiplierConfig:
	# Calcular peso total
	var total_weight = 0.0
	for mult in multipliers:
		total_weight += mult.rarity

	# Escolher aleatoriamente baseado no peso
	var rand_value = randf() * total_weight
	var cumulative = 0.0

	for mult in multipliers:
		cumulative += mult.rarity
		if rand_value <= cumulative:
			return mult

	# Fallback: retorna o primeiro
	return multipliers[0] if multipliers.size() > 0 else null

func choose_weighted_upgrades(player_level: int, player_upgrade_levels: Dictionary, count: int) -> Array[UpgradeConfig]:
	"""Escolhe upgrades baseado em peso/probabilidade calculada pelo nível do player"""
	var weighted_upgrades = []
	var total_weight = 0.0

	# Calcular peso de cada upgrade
	for upgrade in upgrades:
		var current_level = player_upgrade_levels.get(upgrade.upgrade_type, 0)
		var weight = upgrade.get_weight_at_player_level(player_level, current_level)

		if weight > 0:
			weighted_upgrades.append({"upgrade": upgrade, "weight": weight})
			total_weight += weight

	if weighted_upgrades.is_empty():
		print("AVISO: Nenhum upgrade disponível para o nível atual!")
		var empty: Array[UpgradeConfig] = []
		return empty

	# Selecionar N upgrades sem repetição usando weighted random
	var selected: Array[UpgradeConfig] = []
	var remaining = weighted_upgrades.duplicate()

	for i in range(min(count, remaining.size())):
		if remaining.is_empty():
			break

		# Recalcular total_weight
		var current_total = 0.0
		for item in remaining:
			current_total += item.weight

		# Escolher um upgrade baseado no peso
		var rand_value = randf() * current_total
		var cumulative = 0.0

		for j in range(remaining.size()):
			cumulative += remaining[j].weight
			if rand_value <= cumulative:
				selected.append(remaining[j].upgrade)
				remaining.remove_at(j)
				break

	return selected

func show_upgrade_screen():
	if upgrades.size() == 0:
		print("AVISO: Nenhum upgrade configurado!")
		return

	# Pausar o jogo
	get_tree().paused = true

	# Pegar player info
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		print("ERRO: Player não encontrado!")
		get_tree().paused = false
		return

	var player_level = player.current_level if "current_level" in player else 1
	var player_upgrade_levels = player.upgrade_levels if "upgrade_levels" in player else {}

	# Escolher N upgrades baseado em peso/probabilidade
	var selected_upgrades = choose_weighted_upgrades(player_level, player_upgrade_levels, game_config.upgrades_per_selection)

	# Mostrar UI de seleção
	var ui = upgrade_ui_scene.instantiate()
	ui.process_mode = Node.PROCESS_MODE_ALWAYS  # Funciona mesmo com jogo pausado

	# Passar audio_config para a UI
	if audio_config:
		ui.audio_config = audio_config

	add_child(ui)

	# Passar upgrades e níveis atuais do player
	var player_levels = {}
	if player and "upgrade_levels" in player:
		player_levels = player.upgrade_levels

	ui.show_upgrades(selected_upgrades, player_levels)

	# Aguardar seleção
	ui.upgrade_selected.connect(select_upgrade)

func select_upgrade(upgrade: UpgradeConfig):
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("apply_upgrade"):
		player.apply_upgrade(upgrade)

	# Próximo upgrade vem automaticamente no próximo level
	var xp_needed = player.xp_to_next_level if player else 0
	print("Próximo upgrade no level ", player.current_level + 1, " (faltam ", xp_needed - player.current_xp, " XP)")

	# Despausar o jogo
	get_tree().paused = false

# Game Over Management
func _on_combo_changed(count: int):
	if count > max_combo_reached:
		max_combo_reached = count

func on_player_died():
	if is_game_over:
		return

	is_game_over = true
	print("=== GAME OVER ===")

	# Pausar o jogo
	get_tree().paused = true

	# Buscar stats finais do player
	var player = get_tree().get_first_node_in_group("player")
	var final_score = 0
	if player and "power" in player:
		final_score = player.power

	var final_wave = 1
	if current_wave:
		final_wave = current_wave.wave_number

	# Criar e mostrar tela de game over
	var game_over_screen = game_over_screen_scene.instantiate()
	add_child(game_over_screen)

	game_over_screen.show_stats(final_score, final_wave, max_combo_reached)

	# Conectar sinais dos botões
	game_over_screen.restart_requested.connect(restart_game)
	game_over_screen.quit_requested.connect(quit_game)

func restart_game():
	print("Reiniciando jogo...")
	get_tree().paused = false
	get_tree().reload_current_scene()

func quit_game():
	print("Saindo do jogo...")
	get_tree().quit()

# Level Up Management 
func on_player_level_up(new_level: int):
	print("=== PLAYER LEVEL UP ===")
	print("Novo level: ", new_level)

	# Mostrar tela de upgrade (igual antes, mas acionado por level ao invés de threshold)
	show_upgrade_screen()
