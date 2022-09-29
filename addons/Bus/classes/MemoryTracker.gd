class_name MemoryTracker

enum {
	USAGE_BYTE,
	USAGE_KILOBYTE,
	USAGE_MAGABYTE,
	USAGE_GIGABYTE,
#	PRECISIONNANOSECONDS
}

var _StartValue : int
var _StartValueDy : int

func _init(auto_start : bool = true) -> void:
	if auto_start:Start_Restart()

func Start_Restart() -> void:
	_StartValue = OS.get_static_memory_usage()
	_StartValueDy = OS.get_dynamic_memory_usage()

func Usage(pre : int = USAGE_KILOBYTE, dy : bool = false) -> float:
	if dy:
		match pre:
			USAGE_BYTE:
				return (OS.get_dynamic_memory_usage() - _StartValueDy) as float
			USAGE_KILOBYTE:
				return (OS.get_dynamic_memory_usage() - _StartValueDy) / 1024.0 # bytes in kbyte
			USAGE_MAGABYTE:
				return (OS.get_dynamic_memory_usage() - _StartValueDy) / 1048576.0 # bytes in mbyte
			USAGE_GIGABYTE:
				return (OS.get_dynamic_memory_usage() - _StartValueDy) / 1_073_741_824.0 # bytes in gbyte
	else:
		match pre:
			USAGE_BYTE:
				return (OS.get_static_memory_usage() - _StartValue) as float
			USAGE_KILOBYTE:
				return (OS.get_static_memory_usage() - _StartValue) / 1024.0 # bytes in kbyte
			USAGE_MAGABYTE:
				return (OS.get_static_memory_usage() - _StartValue) / 1048576.0 # bytes in mbyte
			USAGE_GIGABYTE:
				return (OS.get_static_memory_usage() - _StartValue) / 1_073_741_824.0 # bytes in gbyte
	return -1.0

func Lap(pre : int = USAGE_KILOBYTE) -> float: # gets value and restart!
	var x : float = Usage(pre, false); Start_Restart(); return x
