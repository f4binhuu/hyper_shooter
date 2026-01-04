extends Area2D

# Sistema de Tiers + Níveis
@export var enemy_config: EnemyConfig  ## Configuração do tier (Swarm/Bruiser/Elite)
@export var enemy_level: int = 1  ## Nível do inimigo (1-5, baseado na wave)

# Propriedades legacy (serão sobrescritas por enemy_config se presente)
@export var speed = 200.0
@export var tilt_amount = 10.0
@export var tilt_speed = 3.0
@export var points_value = 10
@export var xp_value = 1  # XP que dropa ao morrer
@export var max_health = 1
@export var knockback_force = 250.0
@export var audio_config: AudioConfig

@onready var sprite = $Sprite2D
@onready var ui_node = $UI
@onready var level_label = $UI/LevelLabel
@onready var health_bar = $UI/HealthBar
@onready var death_particles = preload("res://assets/particles/enemy_death.tscn")
@onready var floating_text_scene = preload("res://ui/floating_text.tscn")
@onready var hit_impact_scene = preload("res://assets/particles/hit_impact.tscn")

var health = 1
var previous_x = 0.0
var knockback_velocity = Vector2.ZERO
var is_frozen = false
var original_speed = 0.0
var hit_sound: AudioStreamPlayer
var death_sound: AudioStreamPlayer

func _ready():
	add_to_group("enemies")

	# Aplicar configuração de tier + nível ANTES de inicializar
	if enemy_config:
		apply_config_stats()

	health = max_health

	# Atualizar UI
	update_level_label()
	update_health_bar()

	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)
	previous_x = position.x
	original_speed = speed

	# Criar sons de hit e morte
	if audio_config:
		hit_sound = AudioHelper.create_player(
			audio_config.enemy_hit_sound,
			audio_config.enemy_hit_volume,
			self
		)

		death_sound = AudioHelper.create_player(
			audio_config.enemy_death_sound,
			audio_config.enemy_death_volume,
			self
		)

## Aplica stats do EnemyConfig baseado no tier e nível
func apply_config_stats():
	if not enemy_config:
		return

	var stats = enemy_config.get_stats_at_level(enemy_level)

	# Aplicar stats escalados
	max_health = stats.health
	speed = stats.speed
	xp_value = stats.xp
	points_value = stats.points

	# Aplicar sprite e escala visual
	if sprite and enemy_config.sprite:
		sprite.texture = enemy_config.sprite
		sprite.scale = Vector2(enemy_config.base_scale, enemy_config.base_scale)

		# Ajustar posição da UI baseado no tamanho do sprite
		# Sprites maiores precisam da UI mais acima
		if ui_node:
			var sprite_height = sprite.texture.get_height() * enemy_config.base_scale
			var ui_offset = -(sprite_height / 2.0) - 20  # 20px acima do topo do sprite
			ui_node.position.y = ui_offset

	# Aplicar cor modulada por nível (feedback visual)
	if sprite:
		sprite.modulate = enemy_config.get_color_for_level(enemy_level)

	# Ajustar knockback baseado em resistência do tier
	knockback_force = enemy_config.apply_knockback_resistance(knockback_force)

## Atualiza o label de nível
func update_level_label():
	if level_label:
		level_label.text = str(enemy_level)

		# Cor do label baseado no tier
		if enemy_config:
			match enemy_config.tier:
				EnemyConfig.EnemyTier.SWARM:
					level_label.add_theme_color_override("font_color", Color(0.5, 1, 0.5))  # Verde
				EnemyConfig.EnemyTier.BRUISER:
					level_label.add_theme_color_override("font_color", Color(1, 0.8, 0.3))  # Amarelo
				EnemyConfig.EnemyTier.ELITE:
					level_label.add_theme_color_override("font_color", Color(1, 0.5, 1))  # Roxo

## Atualiza a barra de vida
func update_health_bar():
	if health_bar:
		health_bar.max_value = max_health
		health_bar.value = health

		# Cor da barra baseada na porcentagem de vida (verde -> amarelo -> vermelho)
		var health_percent = float(health) / float(max_health)
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
		var style_box = health_bar.get_theme_stylebox("fill").duplicate()
		if style_box is StyleBoxFlat:
			style_box.bg_color = bar_color
			health_bar.add_theme_stylebox_override("fill", style_box)

func _physics_process(delta):
	# Aplicar knockback
	if knockback_velocity.length() > 0:
		position += knockback_velocity * delta
		knockback_velocity = knockback_velocity.lerp(Vector2.ZERO, 5.0 * delta)

	position.y += speed * delta
	var movement_direction = sign(position.x - previous_x)
	var target_rotation = deg_to_rad(movement_direction * tilt_amount) + PI
	sprite.rotation = lerp(sprite.rotation, target_rotation, tilt_speed * delta)
	previous_x = position.x

	if position.y > get_viewport_rect().size.y + 50:
		on_escape_screen()

## Inimigo escapou pela parte inferior da tela - penalidade
func on_escape_screen():
	var player = get_tree().get_first_node_in_group("player")

	if player and player.has_method("take_damage"):
		# Buscar dano de escape configurado no game manager
		var game = get_parent()
		var escape_damage = 15  # default

		if game and game.game_config and "enemy_escape_damage" in game.game_config:
			escape_damage = game.game_config.enemy_escape_damage

		player.take_damage(escape_damage)
		print("INIMIGO ESCAPOU! Player perdeu ", escape_damage, " HP")

		# Feedback visual na posição do escape (borda inferior)
		var escape_pos = Vector2(position.x, get_viewport_rect().size.y - 10)
		spawn_floating_text(tr("ESCAPE"), Color(1, 0.3, 0.3, 1), 32, escape_pos)

	# Destruir o inimigo
	queue_free()

func _on_area_entered(area):
	if area.is_in_group("bullet"):
		# Pegar dano do bullet (se tiver)
		var bullet_damage = 1
		if "damage" in area:
			bullet_damage = area.damage

		# Aplicar knockback baseado na direção do bullet
		if "velocity" in area:
			var knockback_direction = -area.velocity.normalized()
			knockback_velocity = knockback_direction * knockback_force
		else:
			# Se bullet não tem velocity, empurra para cima
			knockback_velocity = Vector2(0, -knockback_force)

		take_damage(bullet_damage)

		# Spawn hit impact particles
		spawn_hit_impact()

		# Pierce: bullet só é destruído se não puder atravessar mais inimigos
		if "pierce_count" in area and "enemies_hit" in area:
			area.enemies_hit += 1

			# Reduzir dano do bullet pela metade a cada hit
			if "damage" in area:
				area.damage = max(1, int(area.damage * 0.5))

			# Destruir bullet se atingiu o limite de pierce
			if area.enemies_hit > area.pierce_count:
				if area.has_method("destroy"):
					area.destroy()
		else:
			# Sem pierce, destruir normalmente
			if area.has_method("destroy"):
				area.destroy()

func take_damage(amount: int, show_text: bool = true):
	health -= amount

	# Atualizar barra de vida
	update_health_bar()

	# Spawn floating damage text
	if show_text:
		spawn_floating_text("-" + str(amount), Color.WHITE, 28)

	if health <= 0:
		die()
	else:
		# Tocar som de hit (não morreu)
		if hit_sound:
			hit_sound.play()

		var original_modulate = sprite.modulate
		# Flash de dano mais intenso
		sprite.modulate = Color(2.0, 2.0, 2.0)
		await get_tree().create_timer(0.08).timeout
		sprite.modulate = original_modulate

func die():
	var player = get_tree().get_first_node_in_group("player")

	# Tocar som de morte (AudioStreamPlayer separado que não será destruído com o inimigo)
	if audio_config:
		AudioHelper.play_sound(
			audio_config.enemy_death_sound,
			audio_config.enemy_death_volume,
			get_parent()
		)

	if player:
		# Dar XP diretamente ao player
		if player.has_method("collect_xp"):
			player.collect_xp(xp_value)

		# Mostrar texto flutuante com XP ganho NO PLAYER (DOPAMINA!)
		var text = floating_text_scene.instantiate()
		text.position = player.position + Vector2(randf_range(-30, 30), -40)  # Um pouco acima do player
		get_parent().add_child(text)
		text.setup("+" + str(xp_value), Color(1, 0.9, 0.2, 1), 48)

		# Adicionar carga de shockwave
		if player.has_method("add_boost_charge"):
			player.add_boost_charge(player.shockwave_charge_per_kill)

		# Registrar kill para combo
		if player.has_method("register_kill"):
			player.register_kill()

		print("Inimigo morto! Player ganhou ", xp_value, " XP")

	spawn_death_particles()
	queue_free()

func hit_by_shockwave(damage: int, player_pos: Vector2):
	if health <= 0:
		return

	# Calcular direção do knockback
	var knockback_direction = (position - player_pos).normalized()
	knockback_velocity = knockback_direction * knockback_force

	# Se vai morrer, dar bonus de power
	if damage >= health:
		var bonus_points = points_value * 2
		var player = get_tree().get_first_node_in_group("player")
		if player:
			player.power += bonus_points
			player.add_boost_charge(player.shockwave_charge_per_kill * 0.5)
			print("SHOCKWAVE KILL! Inimigo destruído! Player ganhou +", bonus_points, " | Força total: ", player.power)

	# Usar função centralizada de dano (que já toca sons, mostra texto e mata se necessário)
	take_damage(damage)

func _on_body_entered(body):
	if body.name == "Player":
		# Inimigo causa dano ao player
		if body.has_method("take_damage"):
			# Buscar dano configurado no game manager
			var game = get_parent()
			var damage = 1  # default
			if game and game.game_config:
				damage = game.game_config.enemy_contact_damage

			body.take_damage(damage)
			print("Inimigo colidiu com player! Causou ", damage, " de dano")

		spawn_death_particles()
		queue_free()

func spawn_death_particles():
	var particles = death_particles.instantiate()
	particles.position = position
	particles.emitting = true
	get_parent().add_child(particles)

	# Auto-destruir partículas após o efeito
	get_tree().create_timer(0.6).timeout.connect(func():
		if particles and is_instance_valid(particles):
			particles.queue_free()
	)

func freeze(duration: float):
	if is_frozen:
		return  # Já está congelado

	is_frozen = true
	speed = 0.0

	# Efeito visual de congelamento (azul claro)
	var original_modulate = sprite.modulate
	sprite.modulate = Color(0.5, 0.8, 1.0)

	# Descongelar após a duração
	await get_tree().create_timer(duration).timeout

	if is_instance_valid(self):
		is_frozen = false
		speed = original_speed
		sprite.modulate = original_modulate
		print("Inimigo descongelado!")

func spawn_floating_text(value: String, color: Color, size: int, custom_pos: Vector2 = Vector2.ZERO):
	var text = floating_text_scene.instantiate()
	text.position = custom_pos if custom_pos != Vector2.ZERO else position
	get_parent().add_child(text)
	text.setup(value, color, size)

func spawn_hit_impact():
	var impact = hit_impact_scene.instantiate()
	impact.position = position
	get_parent().add_child(impact)
