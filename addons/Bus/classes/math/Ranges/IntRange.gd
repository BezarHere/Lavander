class_name IntRange extends NumperRange

func set_minimum(value : float) -> void:
	value = floor(value)
	if value > maximum:
		Exception.OutOfRange("minimum")
		value = maximum - 1
	minimum = value
func get_minimum() -> float:
	return floor(minimum)
func set_maximum(value : float) -> void:
	value = floor(value)
	if value < minimum:
		Exception.OutOfRange("maximum")
		value = minimum + 1
	maximum = value
func get_maximum() -> float:
	return floor(maximum)


func This() -> GDScript: return get_script()
func _init(_min : int = 0, _max : int = 1) -> void:
	rng.randomize()
	minimum = _min; maximum = _max


func ExpandedBy(value : int): 
	return This().new(minimum - value, maximum + value)
func Range01(): return This().new(0, 1)
func Zero(): return This().new(0, 0)

func Expand(by : int) -> void:
	maximum += by; minimum -= by

func Size() -> int: return int(maximum - minimum)
func IsEmpty() -> bool: return maximum == minimum

func Random() -> int: return rng.randi_range(minimum, maximum)

func Clamp(value : float) -> float: return clamp(value, minimum, maximum)

func InRange(value : int) -> bool: return minimum <= value && value <= maximum
func Include(value : int) -> bool: return minimum < value && value < maximum

func Avarge() -> float: return (maximum + minimum) / 2.0

func Accurcy(value : int) -> float: return 1.0 - ( abs( value - Avarge() ) / ( Size() / 2.0 ) )

func _to_string() -> String: return "IntRange(%s,%s)" % [minimum, maximum]

func Push(by : int) -> void:
	minimum += by; maximum += by
func mul(by : int) -> void:
	minimum *= by; maximum *= by
