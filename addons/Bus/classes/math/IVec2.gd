class_name IVec2 extends Reference

var vecInt : Vector2 setget set_vecInt, get_vecInt
var x : int setget set_x
var y : int setget set_y

func set_vecInt(value : Vector2) -> void:
	x = value.x
	y = value.y
	vecInt = value

func get_vecInt() -> Vector2:
	return vecInt.floor()

func set_x(value : int) -> void:
	x = value
	vecInt.x = x

func set_y(value : int) -> void:
	y = value
	vecInt.y = y


func _init(xp : int = 0, yp : int = 0) -> void:
	x = xp; y = yp

func AxisMax() -> int: return int(max(x, y))
func AxisMin() -> int: return int(min(x, y))

func Normalize() -> void:
	x = clamp(x,-1,1)
	y = clamp(y,-1,1)


func Normalized() -> Reference:
	Normalize()
	return self

func IndexCord(i : int):
	var s : IVec2 = get_script().new()
	s.x = i % x; s.y = i / y; return s

func Clone(): get_script().new(x,y)
