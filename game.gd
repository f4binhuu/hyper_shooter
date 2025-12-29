extends Node2D

@onready var enemy_scene = preload("res://enemy.tscn")

var spawn_timer = 0.0
var spawn_interval = 2.0


func _ready() -> void:
	pass

func _process(delta):
	spawn_timer += delta
	
	if spawn_timer >= spawn_interval:
		spawn_enemy()
		spawn_timer = 0.0

func spawn_enemy():
	var enemy = enemy_scene.instantiate()
	var spawn_x = randf_range(50, get_viewport_rect().size.x - 50)
	enemy.position = Vector2(spawn_x, -50)
	add_child(enemy)
