extends PanelContainer

signal card_clicked(config: UpgradeConfig)

var upgrade_config: UpgradeConfig
var current_level: int = 1
var is_hovered: bool = false

@onready var title_label = $MarginContainer/VBoxContainer/TitleLabel
@onready var description_label = $MarginContainer/VBoxContainer/DescriptionLabel
@onready var level_label = $MarginContainer/VBoxContainer/LevelLabel
@onready var panel = $Panel

func _ready():
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	gui_input.connect(_on_gui_input)

func setup(config: UpgradeConfig, level: int):
	upgrade_config = config
	current_level = level

	# Atualizar textos
	title_label.text = tr(config.display_name)
	description_label.text = config.get_description_at_level(level)
	level_label.text = tr("LEVEL_PREFIX") + " " + str(level)

	# Aplicar cor do upgrade
	var style = panel.get_theme_stylebox("panel").duplicate()
	style.border_color = config.icon_color
	style.bg_color = config.icon_color * Color(0.3, 0.3, 0.3, 1.0)
	panel.add_theme_stylebox_override("panel", style)

func _on_mouse_entered():
	is_hovered = true
	# Hover effect
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.05, 1.05), 0.1)

func _on_mouse_exited():
	is_hovered = false
	# Reset scale
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)

func _on_gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		card_clicked.emit(upgrade_config)
