class_name FilesLoader extends ResourceStructure

var _Streams : Array # array of streams

class DataStream:
	
	func _init(f : File, buffer_len : int = -1) -> void:
		if f == null:
			return
		Constructe(f, buffer_len)
	
	func Constructe(f : File, buffer_len : int) -> bool:
		if f.is_open():
			_FilePath = f.get_path_absolute()
			_Stream = f.get_buffer(buffer_len if buffer_len + 1 else f.get_len() - f.get_position())
		else:
			print("FileLoader.DataStream: File is not open")
			_Finalized = false
			return false
		_Finalized = true
		return true
	
	var _Finalized : bool = false
	var _Stream : PoolByteArray
	var _FilePath : String
	var _Id : String
	
	func _to_string() -> String: return _Stream.get_string_from_ascii()
	

func _init(paths : PoolStringArray) -> void:
	var f : File = File.new()
	for num0 in paths.size():
		if !f.file_exists(paths[num0]):
			continue
		f.open(paths[num0], File.READ)
		_Streams.append(DataStream.new(f))
		f.close()

func TotalDataStream() -> PoolByteArray:
	var b : PoolByteArray
	for num0 in _Streams.size():
		b.append_array(_Streams[num0]._Stream)
		b.append_array([241, 142, 214, 51, 21, 0, 0])
	return b
