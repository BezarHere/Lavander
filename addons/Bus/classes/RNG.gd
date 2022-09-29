class_name RNG extends RandomNumberGenerator

export var _SeedsList : PoolIntArray

func _init(random : bool = true) -> void: if random: self.randomize()

func rand64() -> int: return (self.randi() << 31) + self.randi() # depricated
func randi64() -> int: return (self.randi() << 31) + self.randi()
func rand16() -> int: return self.randi() % 65536 # depricated
func randi16() -> int: return self.randi() % 65536
func rand8() -> int: return self.randi() % 256 # depricated
func randi8() -> int: return self.randi() % 256


func rand4(rect : Rect2) -> Vector2: return Vector2(randf_range(rect.position.x, rect.end.x), randf_range(rect.position.y, rect.end.y))
func rand4I(rect : Rect2) -> Vector2: return Vector2(randi_range(rect.position.x, rect.end.x), randi_range(rect.position.y, rect.end.y))
func rand6(ab : AABB) -> Vector3: return Vector3(randf_range(ab.position.x, ab.end.x), randf_range(ab.position.y, ab.end.y), randf_range(ab.position.z, ab.end.z))
func rand6I(ab : AABB) -> Vector3: return Vector3(randi_range(ab.position.x, ab.end.x), randi_range(ab.position.y, ab.end.y), randi_range(ab.position.z, ab.end.z))

func rand_circle(r : float, offset : Vector2 = Vector2.ZERO) -> Vector2: return polar2cartesian(r * self.randf(), TAU * self.randf()) + offset 
func rand_on_circle(r : float, offset : Vector2 = Vector2.ZERO) -> Vector2: return polar2cartesian(r, TAU * self.randf()) + offset 

func rand_item(arr : Array): return null if arr.empty() else arr[self.randi() % arr.size()]

func RoundRandom(v : float) -> int: return int(v) if self.randf() > abs(v) - abs(int(v)) else int(v) + 1

func randb() -> bool: return self.randi() % 2 == 0

func PushSeed(p_seed : int) -> void:
	_SeedsList.append(self.seed)
	self.seed = p_seed

func PopSeed() -> void:
	if _SeedsList.empty():
		push_error("No seed to pop")
		return
	self.seed = _SeedsList[-1]
	_SeedsList.remove(-1)
