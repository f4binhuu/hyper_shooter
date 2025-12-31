extends Node

## Toca um som de forma estática sem precisar gerenciar AudioStreamPlayer
static func play_sound(stream: AudioStream, volume_db: float = 0.0, parent: Node = null) -> AudioStreamPlayer:
	if not stream or not parent:
		return null

	var player = AudioStreamPlayer.new()
	player.stream = stream
	player.volume_db = volume_db
	parent.add_child(player)
	player.play()

	# Auto-destruir após terminar
	player.finished.connect(func():
		player.queue_free()
	)

	return player

## Cria um AudioStreamPlayer permanente (para sons que tocam repetidamente)
static func create_player(stream: AudioStream, volume_db: float = 0.0, parent: Node = null) -> AudioStreamPlayer:
	if not stream or not parent:
		return null

	var player = AudioStreamPlayer.new()
	player.stream = stream
	player.volume_db = volume_db
	parent.add_child(player)

	return player
