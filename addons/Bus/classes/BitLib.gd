# USES LITTLE EDNIAN!
class_name BitFrame
const LITTILE_ENDIAN = true

var _bytes_count : int
var bytes : PoolByteArray = PoolByteArray([]) setget set_bytes
var index : int setget set_index
var bit_index : int setget set_bit_index
var locked_cursor : bool

func set_bit_index(value : int) -> void: bit_index = value % 8
func set_bytes(value : PoolByteArray) -> void:
	_bytes_count = value.size()
	bytes = value
func set_index(value : int) -> void:
	index = value % _bytes_count

func _init(b : PoolByteArray = [], offset : int = -1) -> void:
	construct(b,offset)

func construct(b : PoolByteArray = [], offset : int = -1) -> void:
	set_bytes(b); index = offset


# -------------------------------------------------------------------------
# -------------------------------- READERS --------------------------------
# -------------------------------------------------------------------------

# int 8 (byte)
func read_i8() -> int:
	if !advance():
		exc_eof_reached()
		return 0
	return 128 - bytes[index]

# int 16 (short)
func read_i16() -> int:
	if !advance(2):
		exc_eof_reached()
		return 0
	return 32768 - (bytes[index] << 8) + bytes[index - 1]

# int 32
func read_i32() -> int:
	if !advance(4):
		exc_eof_reached()
		return 0
	return ((bytes[index] << 24) + (bytes[index - 1] << 16) + (bytes[index - 2] << 8) + bytes[index - 3]) - 4294967296

# int 64
func read_i64() -> int:
	if !advance(8):
		exc_eof_reached()
		return 0
	return (bytes[index] << 56) + (bytes[index - 1] << 48) + (bytes[index - 2] << 40) + (bytes[index - 3] << 32) + (bytes[index - 4] << 24) + (bytes[index - 5] << 16) + (bytes[index - 6] << 8) + bytes[index - 7]


# int 8 (byte) unsigned - just normal byte
func read_iu8() -> int:
	if !advance():
		exc_eof_reached()
		return 0
	return bytes[index]

# int 16 (short) unsigned
func read_iu16() -> int:
	if !advance(2):
		exc_eof_reached()
		return 0
	return (bytes[index] << 8) + bytes[index - 1]

# int 32 unsigned
func read_iu32() -> int:
	if !advance(4):
		exc_eof_reached()
		return 0
	return (bytes[index] << 24) + (bytes[index - 1] << 16) + (bytes[index - 2] << 8) + bytes[index - 3]

# int 64 unsigned    ! GODOT/GDSCRIPT DOSN'T ACUTTLY SUPPORT UNSIGNED 64 INTEGERS, THIS CODE MAY RETURN WEIRD BUT PREDICTBLE RESULTS !
# + it uses big-endian which the majority of binery files dosnt use
#func read_iu64() -> int:
#	if !advance(8):
#		exc_eof_reached()
#		return 0
#	return (bytes[index - 7] << 56) + (bytes[index - 6] << 48) + (bytes[index - 5] << 40) + (bytes[index - 4] << 32) + (bytes[index - 3] << 24) + (bytes[index - 2] << 16) + (bytes[index - 1] << 8) + bytes[index]

func read_ascii(l : int) -> String:
	if l <= 0:
		push_error("can't read a negtive or zero length of ascii")
		return ""
	if !advance(l):
		exc_eof_reached()
		return ""
	return bytes.subarray(index - l + 1, index).get_string_from_ascii()

func read_utf8(l : int) -> String:
	if l <= 0:
		push_error("can't read a negtive or zero length of utf8")
		return ""
	if !advance(l):
		exc_eof_reached()
		return ""
	return bytes.subarray(index - l, index).get_string_from_utf8()

func read_bytes(l : int = 1) -> PoolByteArray:
	if l <= 0:
		push_error("can't read a negtive or zero size of bytes")
		return PoolByteArray()
	if !advance(l):
		exc_eof_reached()
		var eof : = PoolByteArray()
		eof.resize(l); return eof
	return bytes.subarray(index - l + 1, index)

# -------------------------------------------------------------------------
# -------------------------------- WRITERS --------------------------------
# -------------------------------------------------------------------------

# Signed and unsinged, godot takes care of much
func write_i64(i : int) -> void:
#	if index <= -1: index = 0
#	if LITTILE_ENDIAN:
#		bytes.insert(index, i >> 52)
#		bytes.insert(index, (i >> 48) & 0xff)
#		bytes.insert(index, (i >> 40) & 0xff)
#		bytes.insert(index, (i >> 32) & 0xff)
#		bytes.insert(index, (i >> 24) & 0xff)
#		bytes.insert(index, (i >> 16) & 0xff)
#		bytes.insert(index, (i >> 8) & 0xff)
#		bytes.insert(index, i & 0xff)
#	else:
#		bytes.insert(index, i & 0xff)
#		bytes.insert(index, (i >> 8) & 0xff)
#		bytes.insert(index, (i >> 16) & 0xff)
#		bytes.insert(index, (i >> 24) & 0xff)
#		bytes.insert(index, (i >> 32) & 0xff)
#		bytes.insert(index, (i >> 40) & 0xff)
#		bytes.insert(index, (i >> 48) & 0xff)
#		bytes.insert(index, i >> 52)
	
	if LITTILE_ENDIAN:
		write_i32(i & 0xffffffff)
		write_i32(i >> 32)
	else:
		write_i32(i >> 32)
		write_i32(i & 0xffffffff)
	
	_bytes_count += 8
	index += 8
	advance(8)

# Signed and unsinged, godot takes care of much
func write_i32(i : int) -> void:
	if index <= -1: index = 0
	
	if LITTILE_ENDIAN:
		bytes.insert(index, i >> 24)
		bytes.insert(index, (i >> 16) & 0xff)
		bytes.insert(index, (i >> 8) & 0xff)
		bytes.insert(index, i & 0xff)
	else:
		bytes.insert(index, i & 0xff)
		bytes.insert(index, (i >> 8) & 0xff)
		bytes.insert(index, (i >> 16) & 0xff)
		bytes.insert(index, i >> 24)
	
	_bytes_count += 4
	index += 4
	advance(4)

# Signed and unsinged, godot takes care of much
func write_i16(i : int) -> void:
	if index <= -1: index = 0
	if LITTILE_ENDIAN:
		bytes.insert(index, i >> 8)
		bytes.insert(index, i & 0xff)
	else:
		bytes.insert(index, i & 0xff)
		bytes.insert(index, i >> 8)

	_bytes_count += 2
	index += 2
	advance(2)

# Signed and unsinged, godot takes care of much
func write_i8(i : int = 0) -> void:
	if index <= -1: index = 0
	bytes.insert(index, i)
	_bytes_count += 1
	index += 1
	advance(1)

func write_ascii(i : String) -> void:
	if index <= -1: index = 0
	var x := i.to_ascii()
	set_bytes(
		(bytes.subarray(0, index - 1) if index else PoolByteArray()) + x + _END()
	)
	index += x.size()
	advance(x.size())

func _END() -> PoolByteArray:
	if index && index < _bytes_count: return bytes.subarray(index, _bytes_count - 1)
	else: return PoolByteArray()

func write_utf8(i : String) -> void:
	if index <= -1: index = 0
	var x := i.to_utf8()
	set_bytes(
		(bytes.subarray(0, index - 1) if index else PoolByteArray()) + x + (bytes.subarray(index, _bytes_count - 1) if index else PoolByteArray())
	)
	advance(x.size())

func write_bytes(i : PoolByteArray) -> void:
	if index <= -1: index = 0
	set_bytes(
		(bytes.subarray(0, index - 1) if index else PoolByteArray()) + i + (bytes.subarray(index, _bytes_count - 1) if index && index < _bytes_count else PoolByteArray())
	)
	index += i.size()
	advance(i.size())

func exc_eof_reached() -> void: push_error("EOF reached: index=%s" % [index])

func advance(i : int = 1) -> bool:
	if locked_cursor: return true
	if index + i >=bytes.size():
		return false
	index += i
	return true

func force_advance(i : int = 1) -> bool:
	if index + i >=_bytes_count: return false
	index += i
	return true

func return(i : int = 1) -> bool:
	if locked_cursor: return true
	if index - i < -1: return false
	index -= i
	return true

func reset_cursor() -> void:
	index = -1

func lock_cursor() -> void: locked_cursor = true
func unlock_cursor() -> void: locked_cursor = false

func gen_checksumed() -> PoolByteArray:
	var b := bytes
	var b0 := hash(b)
	var b1 := hash(PoolByteArray(b).sort())
	b = PoolByteArray([(b0>>24)&0xff,(b0>>16)&0xff,(b0>>8)&0xff,b0&0xff, (b1>>24)&0xff,(b1>>16)&0xff,(b1>>8)&0xff,b1&0xff]) + b
	return b
