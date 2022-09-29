class_name ResourceStructure extends Resource

# Links:
#   ObjectStructure
#   ResourceStructure
#   ReferenceStructure

static func Timestamp(v, b : bool = false) -> Timestamp: return Timestamp.new(v,b)
static func IVec2(x : int, y : int) -> IVec2: return IVec2.new(x,y)
static func TKEYS(id : String, stack : PoolStringArray = []) -> TKEYS: return TKEYS.new().Stack(TKEYS.new(stack), id)
static func REGEX(p : String): return REGEX.new(p)
static func CHANCE(v : float = 1.0) -> CHANCE: return CHANCE.new(v)
static func CACHE(size : int = 256) -> CACHE: return CACHE.new(size)
static func IntRange(v0 : int = 0, v1 : int = 10) -> IntRange: return IntRange.new(v0, v1)
static func FloatingRange(v0 : float = 0, v1 : float = 1) -> FloatingRange: return FloatingRange.new(v0, v1)
static func FloatingChance(v0 : float = 0, v1 : float = 1, chance : float = 1.0, pot : float = 0) -> FloatingChance: return FloatingChance.new().build(v0,v1,chance,pot)
static func Ref(obj : Object, p : String) -> Ref: return Ref.new(obj, p)
