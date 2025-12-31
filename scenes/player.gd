extends CharacterBody2D

@export var fire_rate = 0.5
@export var tilt_amount = 10.0
@export var tilt_speed = 5.0
@export var shockwave_damage = 2
@export var shockwave_cooldown = 5.0
@export var shockwave_charge_per_kill = 15.0
@export var shockwave_radius = 600.0
@export var audio_config: AudioConfig

var power = 20  # Mantido para compatibilidade com score
var shockwave_charge = 0.0
var target_y = 0.0
var has_shield = false

# XP and Level system
var current_level: int = 1
var current_xp: int = 0
var xp_to_next_level: int = 10
var xp_scaling: float = 1.8  # Cada level precisa de 80% mais XP
signal xp_gained(amount: int, current: int, required: int)
signal level_up(new_level: int)

# Health system (HP numérico de 100)
var max_health: int = 100
var current_health: int = 100
var is_invincible: bool = false
var invincibility_timer: float = 0.0
var invincibility_duration: float = 1.0
var health_regen_per_second: float = 0.5  # Regeneração de vida base (0.5 HP/s)
var regen_accumulator: float = 0.0  # Acumula regen para mostrar floating text
signal health_changed(current: int, maximum: int)
signal player_died

# Upgrade tracking
var upgrade_levels = {}
var bullet_damage = 1
var bullet_pierce = 0
var extra_bullets = 0

# Combo system
var combo_count = 0
var combo_timer = 0.0
var combo_window = 2.0  # 2 segundos para manter combo
signal combo_changed(count: int)

@onready var bullet_scene = preload("res://scenes/bullet.tscn")
@onready var shockwave_blast_scene = preload("res://assets/particles/shockwave_blast.tscn")
@onready var floating_text_scene = preload("res://ui/floating_text.tscn")
@onready var sprite = $Sprite2D
@onready var health_bar = $HealthBar

var propulsion_center
var propulsion_left
var propulsion_right
var shoot_sound: AudioStreamPlayer
var shockwave_sound: AudioStreamPlayer

var can_shoot = true
var previous_x = 0.0

func _ready():
	add_to_group("player")

	# Buscar configs de HP do game manager
	var game = get_parent()
	if game and game.game_config:
		max_health = game.game_config.player_max_health
		current_health = max_health
		invincibility_duration = game.game_config.player_invincibility_duration

	health_changed.emit(current_health, max_health)

	# Atualizar barra de vida após todos os nós estarem prontos
	call_deferred("update_health_bar")

	propulsion_center = preload("res://assets/particles/player_propulsion.tscn").instantiate()
	add_child(propulsion_center)
	propulsion_center.position = Vector2(0, 35)
	propulsion_center.scale = Vector2(0.8, 0.5)
	propulsion_center.z_index = -1

	propulsion_left = preload("res://assets/particles/player_propulsion.tscn").instantiate()
	add_child(propulsion_left)
	propulsion_left.position = Vector2(-73, 20)
	propulsion_left.scale = Vector2(0.3, 0.3)
	propulsion_left.z_index = -1

	propulsion_right = preload("res://assets/particles/player_propulsion.tscn").instantiate()
	add_child(propulsion_right)
	propulsion_right.position = Vector2(73, 20)
	propulsion_right.scale = Vector2(0.3, 0.3)
	propulsion_right.z_index = -1

	var viewport_height = get_viewport_rect().size.y
	target_y = viewport_height - 200
	position = Vector2(360, target_y)
	previous_x = position.x

func _physics_process(delta):
	var target_x = get_global_mouse_position().x
	position.x = clamp(target_x, 16, 704)

	if Input.is_action_just_pressed("ui_accept") and shockwave_charge >= 100.0:
		activate_shockwave()

	# Atualizar timer de invencibilidade
	if is_invincible:
		invincibility_timer -= delta
		if invincibility_timer <= 0:
			is_invincible = false
			sprite.modulate = Color(1, 1, 1, 1)  # Volta cor normal

	if shockwave_charge < 100.0:
		shockwave_charge = min(shockwave_charge + (100.0 / shockwave_cooldown) * delta, 100.0)

	# Regeneração de vida
	if health_regen_per_second > 0 and current_health < max_health:
		var regen_amount = health_regen_per_second * delta
		current_health = min(current_health + regen_amount, max_health)
		regen_accumulator += regen_amount

		# Emitir signal e mostrar floating text quando acumula 1 HP
		if regen_accumulator >= 1.0:
			var healed = int(regen_accumulator)
			regen_accumulator -= healed
			health_changed.emit(int(current_health), max_health)
			update_health_bar()
			# Mostrar floating text verde de cura
			spawn_floating_text("+" + str(healed), Color(0.3, 1.0, 0.3), 28)

	# Atualizar combo timer
	if combo_count > 0:
		combo_timer -= delta
		if combo_timer <= 0:
			reset_combo()

	position.y = clamp(position.y, 50, 1230)
	
	var movement_direction = sign(position.x - previous_x)
	var target_rotation = deg_to_rad(movement_direction * tilt_amount)
	
	sprite.rotation = lerp(sprite.rotation, target_rotation, tilt_speed * delta)
	
	previous_x = position.x
	
	if can_shoot:
		shoot()
		can_shoot = false
		await get_tree().create_timer(fire_rate).timeout
		can_shoot = true

func activate_shockwave():
	shockwave_charge = 0.0

	# Criar e tocar som de shockwave (lazy initialization)
	if audio_config and not shockwave_sound:
		shockwave_sound = AudioHelper.create_player(
			audio_config.shockwave_sound,
			audio_config.shockwave_volume,
			self
		)

	if shockwave_sound:
		shockwave_sound.play()

	# Flash branco super intenso no player
	sprite.modulate = Color(5, 5, 5, 1)
	await get_tree().create_timer(0.08).timeout
	sprite.modulate = Color(1, 1, 1, 1)

	# Spawn da explosão visual animada
	var blast = shockwave_blast_scene.instantiate()
	blast.position = position
	get_parent().add_child(blast)

	# Aplicar dano a todos os inimigos no raio
	var enemies = get_tree().get_nodes_in_group("enemies")
	var enemies_hit = 0
	for enemy in enemies:
		if enemy and is_instance_valid(enemy):
			var distance = position.distance_to(enemy.position)
			if distance <= shockwave_radius:
				if enemy.has_method("hit_by_shockwave"):
					enemy.hit_by_shockwave(shockwave_damage, position)
					enemies_hit += 1

	print("SHOCKWAVE ativado! Dano: ", shockwave_damage, " | Raio: ", shockwave_radius, " | Inimigos atingidos: ", enemies_hit)

func shoot():
	var total_bullets = 1 + extra_bullets

	# Criar e tocar som de tiro (lazy initialization)
	if audio_config and not shoot_sound:
		shoot_sound = AudioHelper.create_player(
			audio_config.player_shoot_sound,
			audio_config.player_shoot_volume,
			self
		)

	if shoot_sound:
		shoot_sound.play()

	# Calcular ângulos do leque
	if total_bullets == 1:
		# Apenas 1 bullet - atirar reto
		spawn_bullet(0.0)
	elif total_bullets == 2:
		# 2 bullets - ±15°
		spawn_bullet(deg_to_rad(-15))
		spawn_bullet(deg_to_rad(15))
	elif total_bullets == 3:
		# 3 bullets - 0°, ±20°
		spawn_bullet(0.0)
		spawn_bullet(deg_to_rad(-20))
		spawn_bullet(deg_to_rad(20))
	elif total_bullets == 4:
		# 4 bullets - ±10°, ±30°
		spawn_bullet(deg_to_rad(-10))
		spawn_bullet(deg_to_rad(10))
		spawn_bullet(deg_to_rad(-30))
		spawn_bullet(deg_to_rad(30))
	else:
		# 5+ bullets - distribuir uniformemente
		var angle_step = deg_to_rad(60.0 / (total_bullets - 1))
		var start_angle = deg_to_rad(-30)
		for i in range(total_bullets):
			spawn_bullet(start_angle + (angle_step * i))

func spawn_bullet(angle_offset: float):
	var bullet = bullet_scene.instantiate()
	bullet.position = position + Vector2(0, -20)

	# Calcular velocidade horizontal baseado no ângulo + tilt do player
	var base_angle = sprite.rotation + angle_offset
	bullet.horizontal_speed = sin(base_angle) * 900

	# Aplicar upgrades
	bullet.damage = bullet_damage
	bullet.pierce_count = bullet_pierce

	bullet.z_index = -1
	get_parent().add_child(bullet)

func add_boost_charge(amount: float):
	shockwave_charge = min(shockwave_charge + amount, 100.0)

func apply_multiplier(config):
	print("Multiplicador aplicado: ", config.display_text)

	match config.multiplier_type:
		0:  # MULTIPLY
			var old_power = power
			power = int(power * config.value)
			print("Power multiplicado: ", old_power, " -> ", power)

		1:  # ADD
			var old_power = power
			power += int(config.value)
			print("Power adicionado: ", old_power, " -> ", power)

		2:  # DIVIDE (debuff - protegido por shield)
			if not has_shield:
				var old_power = power
				power = max(1, int(power / config.value))  # Minimo 1
				print("Power dividido: ", old_power, " -> ", power)
			else:
				has_shield = false
				print("SHIELD bloqueou o debuff de divisão!")

		3:  # SUBTRACT (debuff - protegido por shield)
			if not has_shield:
				var old_power = power
				power = max(1, power - int(config.value))  # Minimo 1
				print("Power subtraído: ", old_power, " -> ", power)
			else:
				has_shield = false
				print("SHIELD bloqueou o debuff de subtração!")

		4:  # SHIELD
			has_shield = true
			print("SHIELD ativado! Próximo debuff será bloqueado")

		5:  # FREEZE (congela inimigos)
			freeze_enemies(config.freeze_duration)
			print("Inimigos congelados por ", config.freeze_duration, " segundos")

		6:  # NUKE (destroi todos inimigos)
			nuke_all_enemies()
			print("NUKE ativado! Todos inimigos destruídos")

func freeze_enemies(duration: float):
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if is_instance_valid(enemy) and enemy.has_method("freeze"):
			enemy.freeze(duration)

func nuke_all_enemies():
	var enemies = get_tree().get_nodes_in_group("enemies")
	var count = 0
	for enemy in enemies:
		if is_instance_valid(enemy):
			# Dar pontos por cada inimigo (metade do normal pois não matou manualmente)
			if "points_value" in enemy:
				power += int(enemy.points_value * 0.5)

			# Tocar som de morte
			if audio_config and "audio_config" in enemy:
				AudioHelper.play_sound(
					audio_config.enemy_death_sound,
					audio_config.enemy_death_volume,
					self
				)

			# Spawnar partículas de morte
			if enemy.has_method("spawn_death_particles"):
				enemy.spawn_death_particles()

			enemy.queue_free()
			count += 1

	print("NUKE destruiu ", count, " inimigos")

func apply_upgrade(config: UpgradeConfig):
	# Incrementar nível do upgrade
	var upgrade_name = UpgradeConfig.UpgradeType.keys()[config.upgrade_type]
	if not upgrade_levels.has(upgrade_name):
		upgrade_levels[upgrade_name] = 0

	upgrade_levels[upgrade_name] += 1
	var current_level = upgrade_levels[upgrade_name]

	# Calcular valor do upgrade no nível atual
	var value = config.get_value_at_level(current_level)

	print("=== UPGRADE APLICADO ===")
	print(config.display_name, " - Nível ", current_level)
	print(config.get_description_at_level(current_level))

	# Aplicar efeito baseado no tipo
	match config.upgrade_type:
		UpgradeConfig.UpgradeType.FIRE_RATE:
			fire_rate = max(0.1, fire_rate - value)
			print("Nova cadência: ", fire_rate, "s")

		UpgradeConfig.UpgradeType.DAMAGE:
			bullet_damage += int(value)
			print("Novo dano: ", bullet_damage)

		UpgradeConfig.UpgradeType.MULTI_SHOT:
			extra_bullets += int(value)
			print("Total de projéteis: ", 1 + extra_bullets)

		UpgradeConfig.UpgradeType.PIERCE:
			bullet_pierce += int(value)
			print("Perfuração: ", bullet_pierce, " inimigos")

		UpgradeConfig.UpgradeType.SPEED:
			# TODO: Implementar movimento
			print("Speed upgrade não implementado ainda")

		UpgradeConfig.UpgradeType.SHIELD_BOOST:
			# TODO: Aumentar chance de shield spawnar
			print("Shield boost: +", int(value * 100), "% chance")

		UpgradeConfig.UpgradeType.SHOCKWAVE_BOOST:
			shockwave_damage += int(value)
			print("Novo dano de shockwave: ", shockwave_damage)

		UpgradeConfig.UpgradeType.HEALTH_REGEN:
			health_regen_per_second += value
			print("Regeneração de vida: ", health_regen_per_second, " HP/s")

# Combo system functions
func register_kill():
	combo_count += 1
	combo_timer = combo_window
	combo_changed.emit(combo_count)

	if combo_count > 1:
		print("COMBO x", combo_count, "!")

func reset_combo():
	if combo_count > 0:
		print("Combo perdido!")
	combo_count = 0
	combo_changed.emit(0)

func get_combo_multiplier() -> float:
	if combo_count <= 1:
		return 1.0
	elif combo_count <= 3:
		return 1.5
	elif combo_count <= 5:
		return 2.0
	elif combo_count <= 10:
		return 2.5
	else:
		return 3.0

# Health system functions
## Atualiza a barra de vida visual
func update_health_bar():
	if not health_bar or not is_instance_valid(health_bar):
		return

	health_bar.max_value = max_health
	health_bar.value = current_health

	# Cor da barra baseada na porcentagem de vida (verde -> amarelo -> vermelho)
	var health_percent = float(current_health) / float(max_health) if max_health > 0 else 0.0
	var bar_color: Color

	if health_percent > 0.6:
		# Verde para amarelo
		bar_color = Color(0.2 + (1.0 - health_percent) * 2.0, 0.8, 0.2)
	elif health_percent > 0.3:
		# Amarelo para laranja
		bar_color = Color(1.0, 0.8 - (0.6 - health_percent) * 2.0, 0.2)
	else:
		# Laranja para vermelho
		bar_color = Color(1.0, 0.2 * (health_percent / 0.3), 0.2)

	# Atualizar o estilo da barra dinamicamente
	var style_box = health_bar.get_theme_stylebox("fill")
	if style_box:
		style_box = style_box.duplicate()
		if style_box is StyleBoxFlat:
			style_box.bg_color = bar_color
			health_bar.add_theme_stylebox_override("fill", style_box)

func take_damage(amount: int):
	if is_invincible or current_health <= 0:
		return

	current_health = max(0, current_health - amount)
	health_changed.emit(current_health, max_health)
	update_health_bar()

	# Mostrar floating text de dano
	spawn_floating_text("-" + str(amount), Color(1, 0.3, 0.3), 32)

	print("Player levou ", amount, " de dano! HP: ", current_health, "/", max_health)

	if current_health <= 0:
		die()
	else:
		# Ativar invencibilidade temporária
		is_invincible = true
		invincibility_timer = invincibility_duration

		# Efeito visual de piscar (vermelho)
		start_invincibility_visual()

func start_invincibility_visual():
	# Criar efeito de piscar alternando entre branco e vermelho
	var tween = create_tween()
	tween.set_loops(int(invincibility_duration * 5))  # 5 piscadas por segundo
	tween.tween_property(sprite, "modulate", Color(1, 0.3, 0.3, 0.5), 0.1)
	tween.tween_property(sprite, "modulate", Color(1, 1, 1, 1), 0.1)

func die():
	print("=== PLAYER MORREU ===")
	player_died.emit()

	# Desabilitar controles
	set_physics_process(false)

	# Efeito visual de morte
	sprite.modulate = Color(0.5, 0.5, 0.5, 0.5)

# XP and Level system functions
func collect_xp(amount: int):
	current_xp += amount
	power += amount  # Manter score também para compatibilidade

	print("XP coletado: +", amount, " | Total: ", current_xp, "/", xp_to_next_level)

	# Emitir signal de ganho de XP
	xp_gained.emit(amount, current_xp, xp_to_next_level)

	# Verificar se subiu de level
	if current_xp >= xp_to_next_level:
		level_up_player()

func level_up_player():
	current_level += 1
	current_xp -= xp_to_next_level  # XP excedente vai para próximo level

	# Calcular XP necessário para próximo level (scaling exponencial)
	xp_to_next_level = int(xp_to_next_level * xp_scaling)

	print("=== LEVEL UP! ===")
	print("Level: ", current_level)
	print("Próximo level: ", xp_to_next_level, " XP")

	# Emitir signal de level up
	level_up.emit(current_level)

## Helper function para criar floating text
func spawn_floating_text(value: String, color: Color, size: int):
	var text = floating_text_scene.instantiate()
	text.position = position + Vector2(randf_range(-20, 20), -30)
	get_parent().add_child(text)
	text.setup(value, color, size)
