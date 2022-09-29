class_name Placer

var arr : Array

var size : IVec2 = IVec2.new()

func _init(x : int, y : int, d):
	arr.resize(x * y)
	arr.fill(d)
	size.x = x
	size.y = y
	return self


func Cord2Ind(x : int, y : int) -> int: return (x * size.y) + y

func FillAll(d) -> Placer:
	arr.fill(d)
	return self

func Place(x : int, y : int, d) -> Placer:
	arr[Cord2Ind(x,y)] = d
	return self

func PlaceOn(p : PoolVector2Array, d) -> Placer:
	for x in p:
		arr[Cord2Ind(x.x,x.y)] = d
	return self

func RectFill(x : int, y : int, w : int, h : int, d) -> Placer:
	for i in range(x,x+w): for j in range(y,y+h):
		arr[Cord2Ind(i,j)] = d
	return self

func Rect(x : int, y : int, w : int, h : int, d) -> Placer:
	for i in range(x,x+w): for j in range(y,y+h):
		if (i - x) % (w-1) && j > 0 && j < h - 1: continue
		arr[Cord2Ind(i,j)] = d
	return self

func LineFill(x : int, y : int, w : int, h : int, d) -> Placer:
	Exception.NotImplemnted("LineFill()")
	return self

func Replace(d1, d2) -> Placer:
	for x in arr.size():
		if arr[x] == d1:
			arr[x] = d2
	return self

func CallOnAll(f : FuncRef) -> Placer:
	for x in arr.size(): f.call(arr[x], x)
	return self

func Fill(d) -> Placer:
	arr.fill(d)
	return self

func Results() -> Array: return arr
