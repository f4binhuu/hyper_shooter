extends Area2D

@export var speed = 200.0
@export var tilt_amount = 10.0
@export var tilt_speed = 3.0
@export var points_value = 10
@export var max_health = 1
@export var knockback_force = 250.0

@onready var sprite = $Sprite2D
@onready var death_particles = preload("res://assets/particles/enemy_death.tscn")
@onready var floating_text_scene = preload("res://ui/floating_text.tscn")
@onready var hit_impact_scene = preload("res://assets/particles/hit_impact.tscn")

var health = 1
var previous_x = 0.0
var knockback_velocity = Vector2.ZERO
var is_frozen = false
var original_speed = 0.0

func _ready():
	add_to_group("enemies")
	health = max_health
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)
	previous_x = position.x
	original_speed = speed


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
		queue_free()

func _on_area_entered(area):
	if area.is_in_group("bullet"):
		# Pegar dano do bullet (se tiver)
		var bullet_damage = 1
		if "damage" in area:
			bullet_damage = area.damage

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

func take_damage(amount: int):
	health -= amount

	# Spawn floating damage text
	spawn_floating_text("-" + str(amount), Color.WHITE, 28)

	if health <= 0:
		die()
	else:
		var original_modulate = sprite.modulate
		# Flash de dano mais intenso
		sprite.modulate = Color(2.0, 2.0, 2.0)
		await get_tree().create_timer(0.08).timeout
		sprite.modulate = original_modulate

func die():
	# Dar pontos e carga de shockwave ao player
	var player = get_tree().get_first_node_in_group("player")
	if player:
		var points_earned = points_value

		# Aplicar multiplicador de combo se tiver
		if player.has_method("get_combo_multiplier"):
			var multiplier = player.get_combo_multiplier()
			points_earned = int(points_value * multiplier)

		player.power += points_earned

		if player.has_method("add_boost_charge"):
			player.add_boost_charge(player.shockwave_charge_per_kill)

		# Registrar kill para combo
		if player.has_method("register_kill"):
			player.register_kill()

		# Spawn floating text GRANDE com pontos ganhos
		var text_color = Color.GREEN if points_earned == points_value else Color(1, 0.8, 0)  # Laranja se combo
		spawn_floating_text("+" + str(points_earned), text_color, 40)

		print("Inimigo morto! Player ganhou +", points_earned, " | Força total: ", player.power)

	spawn_death_particles()
	queue_free()

func hit_by_shockwave(damage: int, player_pos: Vector2):
	if health <= 0:
		return

	if damage >= health:
		# Mata o inimigo - dá power em dobro
		var bonus_points = points_value * 2
		var player = get_tree().get_first_node_in_group("player")
		if player:
			player.power += bonus_points
			player.add_boost_charge(player.shockwave_charge_per_kill * 0.5)
			print("SHOCKWAVE KILL! Inimigo LVL 1 destruído! Player ganhou +", bonus_points, " | Força total: ", player.power)

		spawn_death_particles()
		queue_free()
	else:
		# Causa dano e empurra
		take_damage(damage)

		# Calcular direção do knockback
		var knockback_direction = (position - player_pos).normalized()
		knockback_velocity = knockback_direction * knockback_force

		print("Inimigo levou ", damage, " de dano! Vida restante: ", health)

func _on_body_entered(body):
	if body.name == "Player":
		# Inimigo causa dano ao player
		body.power -= points_value
		print("Player atingido! Perdeu -", points_value, " | Força total: ", body.power)
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

func spawn_floating_text(value: String, color: Color, size: int):
	var text = floating_text_scene.instantiate()
	text.position = position
	get_parent().add_child(text)
	text.setup(value, color, size)

func spawn_hit_impact():
	var impact = hit_impact_scene.instantiate()
	impact.position = position
	get_parent().add_child(impact)
