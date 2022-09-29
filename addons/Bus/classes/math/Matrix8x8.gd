class_name Matrix8x8 extends Object

var R0 : Quat = Quat(0,0,0,0)
var R1 : Quat = Quat(0,0,0,0)
var R2 : Quat = Quat(0,0,0,0)
var R3 : Quat = Quat(0,0,0,0)

func Hash() -> int: return hash(R0) ^ (hash(R1) << 2) ^ (hash(R1) << 2) ^ (hash(R2) << 2) ^ (hash(R3) << 2)

func _to_string() -> String:
	return("(%s,%s,%s,%s)" % [R0, R1, R2, R3])
