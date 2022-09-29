"""

This is an abstract class

⚠⚠⚠⚠!!! DONOT INSTANCE OR REFRENCE BY ITSELF !!!

Use IntRange & FloatingRange etc.

"""
class_name NumperRange
const EP = 1.0e-6

var rng : RNG = RNG.new() setget set_rng


func set_rng(value : RNG) -> void:
#	if !Exception.Private("rng"): return
	rng = value

var minimum : float setget set_minimum, get_minimum
var maximum : float setget set_maximum, get_maximum
func set_minimum(value : float) -> void:
	if value > maximum:
		Exception.OutOfRange("minimum")
		value = maximum - EP
	minimum = value
func get_minimum() -> float:
	return minimum
func set_maximum(value : float) -> void:
	if value < minimum:
		Exception.OutOfRange("maximum")
		value = minimum + EP
	maximum = value
func get_maximum() -> float:
	return maximum

func settel_at(f : float) -> void:
	maximum = f; minimum = f

func This() -> GDScript: return get_script()

