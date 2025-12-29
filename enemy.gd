extends Area2D

const INITIAL_HEALTH = 10

@export var speed = 100.0
@export var health = INITIAL_HEALTH
@export var tilt_amount = 15.0
@export var tilt_speed = 3.0

@onready var label = $Label
@onready var sprite = $Sprite2D

var is_converted = false
var previous_x = 0.0

func _ready():
	label.text = str(health)
	area_entered.connect(_on_area_entered)
	previous_x = position.x

func _physics_process(delta):
	position.y += speed * delta
	var movement_direction = sign(position.x - previous_x)
	var target_rotation = deg_to_rad(movement_direction * tilt_amount) + PI
	sprite.rotation = lerp(sprite.rotation, target_rotation, tilt_speed * delta)
	previous_x = position.x
	
	if position.y > get_viewport_rect().size.y + 50:
		queue_free()

func _on_area_entered(area):
	if area.is_in_group("bullet") and area.has_method("destroy"):
		take_damage(1)
		area.destroy()

func take_damage(amount):
	if health > 0 and not is_converted:
		health -= amount
		label.text = str(health)
		
		if health <= 0:
			convert_to_ally()

func convert_to_ally():
	health = INITIAL_HEALTH
	is_converted = true
	sprite.modulate = Color(0.3, 0.7, 1.0)
	label.text = str(health)
