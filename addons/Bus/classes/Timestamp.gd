class_name Timestamp

var value
var tick : int
var ticku : int
var date : int
var global : bool

func _init(v, b : bool = false) -> void:
	value = v;tick = OS.get_ticks_msec(); ticku = OS.get_ticks_usec()
	global = b
	if global: date = OS.get_unix_time()


func _to_string() -> String: return "Timestamp(%s)" % [SU.RemapDic2Str({value=value,tick=tick,ticku=ticku,date=date,global=global} if global else  {value=value,tick=tick,ticku=ticku,global=global})]
