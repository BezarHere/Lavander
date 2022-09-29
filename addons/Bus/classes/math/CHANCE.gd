class_name CHANCE
const MAX_VALUE = 1.01
const MIN_VALUE = -0.01

var rng : RNG = RNG.new()
var value : float = 0 setget set_value, get_value
func set_value(_v : float) -> void:
	value = clamp(_v, MIN_VALUE, MAX_VALUE)
func get_value() -> float: return value


func _init(_v : float) -> void:
	value = _v

func Rand(mul : float = 1.0) -> bool: return value >= 1.0 || rng.randf() < value * mul
