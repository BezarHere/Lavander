class_name FloatingRange extends NumperRange
const VALUE_PRECI = 0.0001


func This() -> GDScript: return get_script()
func _init(_min : float = 0, _max : float = 1) -> void:
	rng.randomize()
	minimum = _min; maximum = _max


func TrueMax() -> float: return max(maximum, minimum)
func TrueMin() -> float: return min(maximum, minimum)

func ExpandedBy(value : float): 
	return This().new(minimum - value, maximum + value)
func Range01(): return This().new(0, 1)
func Zero(): return This().new(0, 0)

func Expand(by : float) -> void:
	maximum += by; minimum -= by

func Size() -> float: return TrueMax() - TrueMin() # Doesnt work well with negtive max
func IsEmpty() -> bool: return abs(TrueMin()) + abs(TrueMax()) <= VALUE_PRECI

func Random() -> float: return rng.randf_range(minimum, maximum)

func RoundRandom() -> int:
	return rng.RoundRandom(rng.randf_range(minimum, maximum))

func Clamp(value : float) -> float: return clamp(value, minimum, maximum)

func InRange(value : float) -> bool: return minimum <= value && value <= maximum
func Include(value : float) -> bool: return minimum < value && value < maximum

func Avarge() -> float: return (TrueMin() + TrueMax()) / 2.0

func Accurcy(value : float) -> float: return 1.0 - ( abs( value - Avarge() ) / ( Size() / 2.0 ) )

func _to_string() -> String: return "FloatingRange(%s,%s)" % [minimum, maximum]

func Push(by : float) -> void:
	minimum += by; maximum += by
func mul(by : float) -> void:
	minimum *= by; maximum *= by

#static func FromString(value : String) -> FloatingRange:
#	var splits : Array = value.split("~", false, 2)
#	if splits.size() != 2:
#		push_error("Invalid string: %s" % value)
#		return FloatingRange.Range01()
#	return FloatingRange.new(splits[0],splits[1])
