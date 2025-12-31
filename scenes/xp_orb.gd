extends Area2D

@export var xp_value: int = 1
@export var attraction_speed: float = 600.0
@export var acceleration: float = 1500.0

var is_attracted: bool = false
var target_player: Node2D = null
var velocity: Vector2 = Vector2.ZERO
var float_timer: float = 0.0
var float_duration: float = 0.3  # Tempo que fica flutuando antes de ser atraído

@onready var glow_particles = $GlowParticles
@onready var core_particles = $CoreParticles
@onready var collect_particles = $CollectParticles

func _ready():
	add_to_group("xp_orbs")

	# Pequeno impulso aleatório inicial
	velocity = Vector2(randf_range(-50, 50), randf_range(-100, -50))

	# Efeito de pulsação nas partículas
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(glow_particles, "scale_amount_max", 8.0, 0.4)
	tween.tween_property(glow_particles, "scale_amount_max", 6.0, 0.4)

	# Conectar colisão com player
	body_entered.connect(_on_body_entered)

func _physics_process(delta):
	# Fase 1: Flutuando no lugar
	if float_timer < float_duration:
		float_timer += delta
		# Aplicar gravidade leve
		velocity.y += 200.0 * delta
		velocity = velocity.lerp(Vector2.ZERO, 2.0 * delta)  # Desacelera
		position += velocity * delta
		return

	# Fase 2: Atrair para o player
	if not is_attracted:
		is_attracted = true
		target_player = get_tree().get_first_node_in_group("player")

	if target_player and is_instance_valid(target_player):
		var direction = (target_player.global_position - global_position).normalized()
		var distance = global_position.distance_to(target_player.global_position)

		# Acelera quanto mais perto do player
		var speed_multiplier = 1.0
		if distance < 200:
			speed_multiplier = 2.0
		if distance < 100:
			speed_multiplier = 3.0

		velocity = velocity.move_toward(direction * attraction_speed * speed_multiplier, acceleration * delta)
		position += velocity * delta

func _on_body_entered(body):
	if body.name == "Player" and body.has_method("collect_xp"):
		body.collect_xp(xp_value)

		# Efeito de coleta - explodir partículas
		collect_particles.emitting = true
		glow_particles.emitting = false
		core_particles.emitting = false

		# Aguardar partículas antes de destruir
		await get_tree().create_timer(0.5).timeout
		queue_free()
