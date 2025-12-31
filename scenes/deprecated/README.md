# Deprecated Enemy Scenes

## Old System (Removed)

These scenes represented the old fixed enemy system where each enemy type was a separate .tscn file:

- `enemy_lvl_2.tscn` - Medium HP enemy (3 HP, 200 speed)
- `enemy_lvl_3.tscn` - Strong/Fast enemy (5 HP, 250 speed)

## New System (Current)

The game now uses a **Tier + Level** system:

### Single Base Scene
- `scenes/enemy.tscn` - Universal enemy scene

### Configuration-Driven
- `resources/enemies/enemy_config_swarm.tres` (Tier 1)
- `resources/enemies/enemy_config_bruiser.tres` (Tier 2)
- `resources/enemies/enemy_config_elite.tres` (Tier 3)

### Dynamic Leveling
Enemies scale automatically based on wave number:
- **Level 1-5** within each tier
- Stats calculated via `EnemyConfig.get_stats_at_level()`
- Visual feedback through color modulation

## Why Changed?

**Old System Problems:**
- Fixed stats per enemy type (no progression)
- Same XP/points regardless of wave
- Required creating new .tscn for each variant
- No tier/archetype system

**New System Benefits:**
- ✅ Enemies evolve with waves (5 levels × 3 tiers = 15 variants)
- ✅ Rewards scale with difficulty
- ✅ Single base scene + config files
- ✅ Clear archetypes (Swarm, Bruiser, Elite)
- ✅ Easy balancing via config tweaks
- ✅ Visual level feedback (color tint)

## Mapping

Old → New equivalent:

```
enemy_lvl_2.tscn  →  enemy.tscn + enemy_config_bruiser.tres (Level 1)
enemy_lvl_3.tscn  →  enemy.tscn + enemy_config_elite.tres (Level 1)
```

These files are kept for reference only.
