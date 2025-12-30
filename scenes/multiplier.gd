extends Area2D

@export var config: MultiplierConfig

@onready var sprite = $Sprite2D
@onready var label = $Label

func _ready():
	if not config:
		push_error("Multiplier sem configuração!")
		queue_free()
		return

	# Configurar visual baseado no config
	sprite.modulate = config.color
	label.text = config.display_text

	# Conectar sinal de colisão com projéteis
	area_entered.connect(_on_area_entered)

func _physics_process(delta):
	# Desce pela tela
	position.y += config.speed * delta

	# Remove se sair da tela
	if position.y > get_viewport_rect().size.y + 50:
		queue_free()

func _on_area_entered(area):
	# Quando atingido por uma bala
	if area.is_in_group("bullet"):
		activate()
		if area.has_method("destroy"):
			area.destroy()

func activate():
	# Encontrar o player e aplicar efeito
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("apply_multiplier"):
		player.apply_multiplier(config)

	# Feedback visual: partículas ou flash
	spawn_activation_particles()

	# Auto-destruir
	queue_free()

func spawn_activation_particles():
	# Criar partículas usando CPUParticles2D dinamicamente
	var particles = CPUParticles2D.new()
	particles.position = position
	particles.emitting = true
	particles.one_shot = true
	particles.explosiveness = 1.0
	particles.amount = 20
	particles.lifetime = 0.6
	particles.speed_scale = 2.0

	# Configurações de emissão
	particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	particles.emission_sphere_radius = 20.0

	# Propriedades das partículas
	particles.direction = Vector2(0, -1)
	particles.spread = 180.0
	particles.gravity = Vector2(0, 200)
	particles.initial_velocity_min = 100.0
	particles.initial_velocity_max = 200.0
	particles.angular_velocity_min = -360.0
	particles.angular_velocity_max = 360.0

	# Visual
	particles.scale_amount_min = 4.0
	particles.scale_amount_max = 8.0
	particles.color = config.color

	get_parent().add_child(particles)

	# Auto-destruir após animação
	await get_tree().create_timer(0.7).timeout
	if particles and is_instance_valid(particles):
		particles.queue_free()
