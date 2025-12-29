extends Area2D

@export var speed = 900.0

var trail
var is_destroyed = false
var horizontal_speed = 0.0

# Upgrade properties
var damage = 1
var pierce_count = 0  # Quantos inimigos pode atravessar
var enemies_hit = 0   # Quantos já atingiu

func _ready():
	add_to_group("bullet")
	
	var trail_scene = preload("res://particles/bullet_trail.tscn")
	trail = trail_scene.instantiate()
	trail.z_index = -2
	get_parent().add_child(trail)
	trail.position = position

func _physics_process(delta):
	if not is_destroyed:
		position.y -= speed * delta
		position.x += horizontal_speed * delta
		
		var angle = atan2(-speed, horizontal_speed)
		rotation = angle + PI/2
		
		if trail:
			trail.position = position
	
	if position.y < -50:
		destroy()

func destroy():
	if is_destroyed:
		return
	
	is_destroyed = true
	
	if trail:
		trail.emitting = false
		get_tree().create_timer(0.3).timeout.connect(func(): 
			if trail:
				trail.queue_free()
		)
	
	queue_free()
