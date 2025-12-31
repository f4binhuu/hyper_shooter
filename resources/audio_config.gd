extends Resource
class_name AudioConfig

enum SoundType {
	PLAYER_SHOOT,
	PLAYER_SHOCKWAVE,
	ENEMY_HIT,
	ENEMY_DEATH,
	UPGRADE_COMMON,
	UPGRADE_UNCOMMON,
	UPGRADE_RARE,
	UPGRADE_EPIC
}

# === PLAYER SOUNDS ===
@export_group("Player Sounds")
@export var player_shoot_sound: AudioStream
@export var player_shoot_volume: float = -5.0

@export var shockwave_sound: AudioStream
@export var shockwave_volume: float = 0.0

# === ENEMY SOUNDS ===
@export_group("Enemy Sounds")
@export var enemy_hit_sound: AudioStream
@export var enemy_hit_volume: float = -5.0

@export var enemy_death_sound: AudioStream
@export var enemy_death_volume: float = 0.0

# === UPGRADE SOUNDS ===
@export_group("Upgrade Sounds")
@export var upgrade_common_sound: AudioStream
@export var upgrade_common_volume: float = 0.0

@export var upgrade_uncommon_sound: AudioStream
@export var upgrade_uncommon_volume: float = 0.0

@export var upgrade_rare_sound: AudioStream
@export var upgrade_rare_volume: float = 0.0

@export var upgrade_epic_sound: AudioStream
@export var upgrade_epic_volume: float = 0.0

# Helper functions para acessar via enum
func get_sound(type: SoundType) -> AudioStream:
	match type:
		SoundType.PLAYER_SHOOT:
			return player_shoot_sound
		SoundType.PLAYER_SHOCKWAVE:
			return shockwave_sound
		SoundType.ENEMY_HIT:
			return enemy_hit_sound
		SoundType.ENEMY_DEATH:
			return enemy_death_sound
		SoundType.UPGRADE_COMMON:
			return upgrade_common_sound
		SoundType.UPGRADE_UNCOMMON:
			return upgrade_uncommon_sound
		SoundType.UPGRADE_RARE:
			return upgrade_rare_sound
		SoundType.UPGRADE_EPIC:
			return upgrade_epic_sound
		_:
			return null

func get_volume(type: SoundType) -> float:
	match type:
		SoundType.PLAYER_SHOOT:
			return player_shoot_volume
		SoundType.PLAYER_SHOCKWAVE:
			return shockwave_volume
		SoundType.ENEMY_HIT:
			return enemy_hit_volume
		SoundType.ENEMY_DEATH:
			return enemy_death_volume
		SoundType.UPGRADE_COMMON:
			return upgrade_common_volume
		SoundType.UPGRADE_UNCOMMON:
			return upgrade_uncommon_volume
		SoundType.UPGRADE_RARE:
			return upgrade_rare_volume
		SoundType.UPGRADE_EPIC:
			return upgrade_epic_volume
		_:
			return 0.0
