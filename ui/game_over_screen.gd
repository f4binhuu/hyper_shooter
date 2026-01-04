extends CanvasLayer

signal restart_requested
signal quit_requested

@onready var final_score_label = $Panel/VBoxContainer/FinalScoreLabel
@onready var wave_label = $Panel/VBoxContainer/WaveLabel
@onready var combo_label = $Panel/VBoxContainer/ComboLabel
@onready var restart_button = $Panel/VBoxContainer/RestartButton
@onready var quit_button = $Panel/VBoxContainer/QuitButton
@onready var panel = $Panel

func _ready():
	# Garantir que funciona enquanto o jogo está pausado
	process_mode = Node.PROCESS_MODE_ALWAYS

	# Conectar botões
	restart_button.pressed.connect(_on_restart_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

	# Animar entrada
	panel.modulate = Color(1, 1, 1, 0)
	panel.scale = Vector2(0.8, 0.8)

	var tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(panel, "modulate", Color(1, 1, 1, 1), 0.3)
	tween.parallel().tween_property(panel, "scale", Vector2(1.0, 1.0), 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func show_stats(score: int, wave: int, max_combo: int):
	final_score_label.text = tr("FINAL_SCORE") + ": " + str(score)
	wave_label.text = tr("WAVE_REACHED") + ": " + str(wave)
	combo_label.text = tr("MAX_COMBO") + ": x" + str(max_combo)

func _on_restart_pressed():
	restart_requested.emit()

func _on_quit_pressed():
	quit_requested.emit()
