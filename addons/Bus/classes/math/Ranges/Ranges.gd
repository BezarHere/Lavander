class_name RANGES extends ObjectStructure

func _init() -> void: Exception.StaticViolation("RANGES")

static func int2float(i : IntRange) -> FloatingRange: return FloatingRange(i.minimum, i.maximum)
static func float2int(i : FloatingRange) -> IntRange: return IntRange(i.minimum, i.maximum)
static func Convert(obj : NumperRange, to : NumperRange) -> NumperRange:
	if obj == null || to == null: return to
	
	if to is IntRange: return IntRange(obj.minimum, obj.maximum)
	
	if to is FloatingChance: return FloatingChance(obj.minimum, obj.maximum, 1.0, 0.0)
	if to is FloatingRange: return FloatingRange(obj.minimum, obj.maximum)
	
	
	return to
