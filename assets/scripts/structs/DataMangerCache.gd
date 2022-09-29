class_name DMCache extends ResourceStructure
const BUFFER_ID : String = "DMC"

var Data : Dictionary
var DataString : String

var buffer : PoolByteArray
var path : String
var error : String
var CurrentChecksum : int

func Load(_path : String) -> void:
	path = _path
	var f : File = File.new()
	f.open(path, File.READ)
	buffer = f.get_buffer(f.get_len())
	f.close()
	ParseBuffer()

func Save(save : String) -> void:
	var bit : BitFrame = BitFrame.new()
	bit.write_ascii(BUFFER_ID)
	bit.write_bytes(VERSION_CTRL.VERSION_ARR)
	UpdateDataString()
	var b : PoolByteArray = DataString.to_ascii()
	var b0 : int = b.size()
	b = b.compress(2)
	bit.write_i32(hash(b))
	bit.write_i32(hash(Data))
	bit.write_i32(b0)
	bit.write_bytes(b)
	var f : File = File.new()
	f.open(save, File.WRITE)
	f.store_buffer(bit.bytes)
	f.close()

func Checksum(d) -> int:
	return hash(d) + (hash(var2bytes(d, true)) << 31)

func UpdateDataString() -> void:
	DataString = var2str(Data)

func ParseBuffer() -> void:
	error = ""
	var bit : BitFrame = BitFrame.new(buffer)
	if bit.read_ascii(3) != BUFFER_ID:
		Log.Error("Invalid id for data cache")
		error = "inv_id"
		return
	var version : = bit.read_bytes(3)
	if !VERSION_CTRL.IsSupportedCacheVer(version):
		Log.Error("outrange version for data cache, Current version: %s, data version: %s" % [VERSION_CTRL.VERSION(), VERSION_CTRL.VERSION(version)])
		error = "outrange_version"
		return
	var checksum : int = bit.read_iu32()
	var checksum_data : int = bit.read_iu32()
	if checksum_data != CurrentChecksum:
		return
	var size : int = bit.read_iu32()
	var data : PoolByteArray = bit.read_bytes((bit.bytes.size() - bit.index)- 1)
	var data_hash : int = hash(data)
	if !checksum == data_hash:
		Log.Error("Invalid cache")
		error = "invalid_cache_cf"
		return
	data = data.decompress(size, 2)
	var text : String = data.get_string_from_ascii()
	var traw = parse_json(text)
	if !traw is Dictionary:
		Log.Error("Invalid cache")
		error = "invalid_cache_it"
		return
	Data = traw
	SU.SaveToFile(DataManger.GAMEDATAFOLDER().plus_file("cache.json"), JSON.print(Data, "\t"))



