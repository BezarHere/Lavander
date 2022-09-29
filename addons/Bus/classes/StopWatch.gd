class_name StopWatch extends StructureBase

enum {
	PRECISIONMILISECONDS,
	PRECISIONNANOSECONDS
}

var _StartCounter : int
var _Precision : int

func _init(auto_start : bool = true, pres : int = PRECISIONMILISECONDS) -> void:
	_Precision = pres % 2; if auto_start:Start_Restart()

func Start_Restart() -> void:
	if _Precision == PRECISIONMILISECONDS:
		_StartCounter=OS.get_ticks_msec()
	elif _Precision == PRECISIONNANOSECONDS:
		_StartCounter=OS.get_ticks_usec()

func TimePassed(free_after : bool = true) -> int:
	if free_after: QueueFree()
	if _Precision == PRECISIONMILISECONDS:
		return OS.get_ticks_msec() - _StartCounter
	elif _Precision == PRECISIONNANOSECONDS:
		return OS.get_ticks_usec() - _StartCounter
	return 0


func ToMSec() -> float:
	if _Precision == PRECISIONMILISECONDS:
		return _StartCounter as float
	elif _Precision == PRECISIONNANOSECONDS:
		return _StartCounter / 1000.0
	return _StartCounter / 1000.0

func ToUSec() -> float:
	if _Precision == PRECISIONMILISECONDS:
		return _StartCounter / 1000.0
	elif _Precision == PRECISIONNANOSECONDS:
		return _StartCounter as float
	return _StartCounter / 1000000.0

func _to_string() -> String:
	return str(TimePassed(false))
