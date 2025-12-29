extends Resource
class_name MultiplierConfig

## Configuração de um Multiplicador (Power-up/Debuff)

enum MultiplierType {
	MULTIPLY,   # x2, x3
	ADD,        # +50, +100
	DIVIDE,     # ÷2
	SUBTRACT,   # -50, -100
	SHIELD,     # Protege do próximo debuff
	FREEZE,     # Congela inimigos
	NUKE        # Destroi todos os inimigos
}

@export_group("Tipo e Valor")
@export var multiplier_type: MultiplierType = MultiplierType.ADD
@export var value: float = 50.0
@export var display_text: String = "+50"

@export_group("Visual")
@export var color: Color = Color(0, 1, 0, 1)  # Verde padrão

@export_group("Spawn")
@export_range(0.01, 1.0, 0.01) var rarity: float = 0.20  # Chance relativa de spawn
@export_range(50.0, 300.0, 10.0) var speed: float = 100.0

@export_group("Especiais (apenas para tipos especiais)")
@export var freeze_duration: float = 3.0  # Segundos (só para FREEZE)
