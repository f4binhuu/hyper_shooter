extends CharacterBody2D

@export var fire_rate = 0.5
@export var tilt_amount = 10.0
@export var tilt_speed = 5.0

@onready var bullet_scene = preload("res://bullet.tscn")
@onready var sprite = $Sprite2D

var can_shoot = true
var previous_x = 0.0

func _ready():
	var propulsion_center = preload("res://player_propulsion.tscn").instantiate()
	add_child(propulsion_center)
	propulsion_center.position = Vector2(0, 35)
	propulsion_center.scale = Vector2(0.8, 0.5)
	propulsion_center.z_index = -1
	
	var propulsion_left = preload("res://player_propulsion.tscn").instantiate()
	add_child(propulsion_left)
	propulsion_left.position = Vector2(-73, 20)
	propulsion_left.scale = Vector2(0.3, 0.3)
	propulsion_left.z_index = -1
	
	var propulsion_right = preload("res://player_propulsion.tscn").instantiate()
	add_child(propulsion_right)
	propulsion_right.position = Vector2(73, 20)
	propulsion_right.scale = Vector2(0.3, 0.3)
	propulsion_right.z_index = -1
	
	var viewport_height = get_viewport_rect().size.y
	position = Vector2(360, viewport_height - 200)
	previous_x = position.x


func _physics_process(delta):
	var target_x = get_global_mouse_position().x
	position.x = clamp(target_x, 16, 704)
	
	var movement_direction = sign(position.x - previous_x)
	var target_rotation = deg_to_rad(movement_direction * tilt_amount)
	
	sprite.rotation = lerp(sprite.rotation, target_rotation, tilt_speed * delta)
	
	previous_x = position.x
	
	if can_shoot:
		shoot()
		can_shoot = false
		await get_tree().create_timer(fire_rate).timeout
		can_shoot = true

func shoot():
	var bullet = bullet_scene.instantiate()
	bullet.position = position + Vector2(0, -20)
	bullet.horizontal_speed = sprite.rotation * 300
	bullet.z_index = -1
	get_parent().add_child(bullet)
