"""

Any suggestion or optimaizations?
DM me on DISCORD or submit a issue to my GITHUP!

"""

class_name long
const int64 : int = 9223372036854775807
const uint64 : String = "18446744073709551616"
const SIZE = 32


# Max: 57896044618658097711785492504343953926634992332820282019728792003956564819967
# Min: -57896044618658097711785492504343953926634992332820282019728792003956564819968
# Why need more??

# Please don't edit this your self, the code may break if editied
var sign_ : bool # True == negtive
var __ : PoolByteArray

# X is value and y is the exponet
func _init(x = null, y : int = 0) -> void:
	__.resize(SIZE)
	__.fill(0)
	if x is float: x = int(x)
	elif x is String: x = int(x)
	if x is int:
		sign_ = sign(x) == -1
		for i in 8:
			if i + y >= SIZE:
				Exception.Overflow("i,y")
				return
			__[i + y] = (x >> (i * 8)) & 0xff
			print((x >> (i * 8)) & 0xff)
	elif x is Reference:
		__ = x.__
		sign_ = x.sign_

# Converters:

# i1 will make it overflow
func ToInt(s : int = 8) -> int:
	var res : int
	for x in 8:
		res += __[x] << (x * 8)
	if sign_: return -res; else: return res 
#	return -1

func to_hex() -> String: return __.hex_encode()

func _to_string() -> String:
	var i0 : int = bytes_to_int(__.subarray(0, 7))
	var i1 : int = bytes_to_int(__.subarray(8, 15))
	var i2 : int = bytes_to_int(__.subarray(16, 23))
	var i3 : int = bytes_to_int(__.subarray(24, 31))
	
	var result : String
	var carry : int
	
	for x in SIZE:
		result
	
	return result


static func bytes_to_int(byte : PoolByteArray) -> int:
	var r : int; for x in byte.size(): r += byte[x] << (x * 8); return r

# Oprations:


