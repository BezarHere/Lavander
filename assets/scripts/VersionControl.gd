class_name VERSION_CTRL extends Node
static func VERSION(v : Array = VERSION_ARR) -> int: return v[0] | v[1] << 8 | v[2] << 16
const VERSION_ARR = [0,0,1]
static func IsSupportedCacheVer(ver : PoolByteArray) -> bool:
	var num : int = VERSION(ver)
	var num2 : int = VERSION()
	return num >= num2 && num < num2 + 256
static func IsSupportedSaveVersion(ver : PoolByteArray) -> bool:
	var num : int = VERSION(ver)
	var num2 : int = VERSION()
	return num >= num2 && num < num2 + 256
