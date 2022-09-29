class_name FloatingChance extends FloatingRange

export var Pot : float = 0.0
export var Chance : float = 1.0 setget SetChance

func SetChance(value : float) -> void:
	if value < 0 || value > 1: Exception.ThrewS("Chance", Exception.ERR_PARAMTER_OUT_OF_RANGE)
	Chance = clamp(value, 0, 1)

func Random() -> float:
	if rng.randf() > Chance: return Pot
	return rng.randf_range(minimum, maximum)

func build(v1 : float, v2 : float, v3 : float, v4 : float):
	minimum = v1; maximum = v2
	Chance = v3; Pot = v4
	return self
