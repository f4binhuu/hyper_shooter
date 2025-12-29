extends Node2D

@onready var enemy_scene = preload("res://elements/enemy.tscn")
@onready var multiplier_scene = preload("res://elements/multiplier.tscn")
@onready var upgrade_ui_scene = preload("res://ui/upgrade_selection_ui.tscn")

@export var waves: Array[WaveConfig] = []
@export var loop_waves: bool = true  # Repetir waves quando acabar

@export_group("Multipliers")
@export var multipliers: Array[MultiplierConfig] = []
@export_range(3.0, 15.0, 0.5) var multiplier_spawn_interval: float = 7.0

@export_group("Upgrades")
@export var upgrades: Array[UpgradeConfig] = []
@export var upgrade_point_threshold: int = 500
@export var upgrade_scaling_multiplier: float = 1.8

var current_wave_index: int = 0
var current_wave: WaveConfig
var wave_timer: float = 0.0
var spawn_timer: float = 0.0
var multiplier_timer: float = 0.0
var enemies_killed_this_wave: int = 0
var next_upgrade_at: int = 500
var last_power_check: int = 0

signal wave_started(wave_number: int)
signal wave_completed(wave_number: int)


func _ready() -> void:
	next_upgrade_at = upgrade_point_threshold

	if waves.size() > 0:
		start_wave(0)
	else:
		print("AVISO: Nenhuma wave configurada! Adicione waves no Inspector.")

func _process(delta):
	if not current_wave:
		return

	# Timer de spawn de inimigos
	spawn_timer += delta

	if spawn_timer >= current_wave.spawn_interval:
		spawn_enemies()
		spawn_timer = 0.0

	# Timer de spawn de multiplicadores
	multiplier_timer += delta

	if multiplier_timer >= multiplier_spawn_interval:
		spawn_multiplier()
		multiplier_timer = 0.0

	# Timer de duração da wave (se configurado)
	if current_wave.wave_duration > 0:
		wave_timer += delta
		if wave_timer >= current_wave.wave_duration:
			complete_wave()

	# Verificar threshold de upgrade
	check_upgrade_threshold()

func start_wave(wave_index: int):
	if wave_index >= waves.size():
		if loop_waves:
			wave_index = 0  # Reinicia do começo
		else:
			print("Todas as waves completadas!")
			return

	current_wave_index = wave_index
	current_wave = waves[wave_index]
	wave_timer = 0.0
	spawn_timer = 0.0
	enemies_killed_this_wave = 0

	wave_started.emit(current_wave.wave_number)
	print("=== WAVE ", current_wave.wave_number, " INICIADA ===")
	print(current_wave.wave_description)

func complete_wave():
	wave_completed.emit(current_wave.wave_number)
	print("=== WAVE ", current_wave.wave_number, " COMPLETADA ===")

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
	# Spawnar múltiplos inimigos de uma vez
	for i in range(current_wave.enemies_per_spawn):
		var enemy = enemy_scene.instantiate()
		var spawn_x = randf_range(50, get_viewport_rect().size.x - 50)
		enemy.position = Vector2(spawn_x, -50)

		# Configurar propriedades do inimigo baseado na wave
		enemy.max_health = current_wave.enemy_health
		enemy.speed = current_wave.enemy_speed
		enemy.points_value = current_wave.enemy_points

		add_child(enemy)

		# Conectar sinal de morte do inimigo
		enemy.tree_exited.connect(on_enemy_killed)

		# Pequeno delay entre cada spawn
		await get_tree().create_timer(0.1).timeout

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

func check_upgrade_threshold():
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return

	# Verificar se atingiu o threshold
	if player.power >= next_upgrade_at and player.power != last_power_check:
		last_power_check = player.power
		show_upgrade_screen()

func show_upgrade_screen():
	if upgrades.size() == 0:
		print("AVISO: Nenhum upgrade configurado!")
		return

	# Pausar o jogo
	get_tree().paused = true

	# Escolher 3 upgrades aleatórios
	var available_upgrades = upgrades.duplicate()
	available_upgrades.shuffle()

	var selected_upgrades = []
	for i in range(min(3, available_upgrades.size())):
		selected_upgrades.append(available_upgrades[i])

	# Mostrar UI de seleção
	var ui = upgrade_ui_scene.instantiate()
	ui.process_mode = Node.PROCESS_MODE_ALWAYS  # Funciona mesmo com jogo pausado
	add_child(ui)

	# Passar upgrades e níveis atuais do player
	var player = get_tree().get_first_node_in_group("player")
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

	# Atualizar threshold para próximo upgrade com scaling multiplicativo
	var current_threshold = next_upgrade_at
	next_upgrade_at = int(current_threshold * upgrade_scaling_multiplier)

	print("Próximo upgrade em: ", next_upgrade_at, " pontos (", next_upgrade_at - player.power, " restantes)")

	# Despausar o jogo
	get_tree().paused = false
