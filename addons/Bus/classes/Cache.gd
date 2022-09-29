class_name CACHE

var _arr : Array
var dirty : bool setget set_dirty
var size : int

func set_dirty(value : bool) -> void:
	if !Exception.Private("dirty"): return
	dirty = value

func set_size(value : int) -> void:
	if !Exception.Private("size"): return
	size = value



func _init(s : int) -> void:
	size = s



func Add(v, ignore_limit : bool = false) -> void:
	_arr.append(v)
	MarkDirty()

func Remove(i : int) -> void:
	_arr.remove(i)

func Erase(v) -> void:
	_arr.erase(v)
	MarkDirty()

func Clear() -> void:
	_arr.clear()
	dirty = false

func List() -> Array: return _arr.duplicate()

func Amount() -> int: return _arr.size()

func Grap(index : int):
	var a : int = Amount()
	if index < -a || index >= a:
		Exception.OutOfRange("index")
		return
	return _arr[index]


func Resize(to : int) -> void:
	if to <= 0:
		Exception.OutOfRange("size")
		return
	size = to
	MarkDirty()

func MarkDirty() -> void:
	if !dirty:
		dirty = true
		call_deferred("Clean")

func Clean() -> void:
	if !Exception.Private("Clean", true): return
	if !dirty: return
	dirty = false
	if _arr.size() <= size: return
	var overflow : int = _arr.size() - size
	var new_arr : Array
	for x in size:
		new_arr.append(_arr[x + overflow])
	_arr = new_arr
