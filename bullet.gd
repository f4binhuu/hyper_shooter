extends Area2D

@export var speed = 500.0

var trail
var is_destroyed = false
var horizontal_speed = 0.0

func _ready():
	add_to_group("bullet")
	
	var trail_scene = preload("res://player_trail.tscn")
	trail = trail_scene.instantiate()
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
