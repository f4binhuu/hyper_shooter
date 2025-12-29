extends Sprite2D

@export var scroll_speed = 200.0

func _process(delta):
	position.y += scroll_speed * delta
	
	if position.y > 1280:
		position.y = -640
