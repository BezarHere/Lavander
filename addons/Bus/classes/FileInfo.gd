class_name FileInfo

var path : String setget set_path
var extension : String
var filename : String
var directory : String
var size : int # In Bytes

func set_path(value : String) -> void:
	path = value
	extension = path.get_extension()
	filename = path.get_basename()
	directory = path.get_base_dir()

func duplicate() -> FileInfo:
	var a : FileInfo = get_script().new()
	a.path = path
	a.size = size
	return a

func from_file(f : File) -> void:
	if !f.is_open():
		Exception.Threw("f", ERR_CANT_CREATE)
		return
	path = f.get_path()
	size = f.get_len()
