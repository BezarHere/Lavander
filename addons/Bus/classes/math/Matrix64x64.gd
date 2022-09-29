class_name Matrix64x64 extends Object
const SIZE = 4096

var Values : PoolRealArray

func _init() -> void:
	Values.resize(SIZE)

func Hash() -> int: return hash(Values)

func _to_string() -> String:
	var s : String = str(Values)
	return s.substr(1, s.length() - 2).insert(0, "(").insert(s.length() - 1, ")")
