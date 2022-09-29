extends Node
var DEPUG = false
signal log_fired(type, text)


var flush_intervnal : int = 4
var _fic : int
var history : Array

func Error(text : String) -> void:
	push_error(text)
	var p := {
		type = "err",
		text = text,
		time = Time.get_unix_time_from_system(),
		stack = get_stack().slice(1, -1)
	}
	history.append(p)
	emit_signal("log_fired", p)
	QueueFlush()


func Warning(text : String) -> void:
	push_warning(text)
	var p := {
		type = "wrn",
		text = text,
		time = Time.get_unix_time_from_system(),
		stack = get_stack().slice(1, -1)
	}
	history.append(p)
	emit_signal("log_fired", p)
	QueueFlush()

func Massege(text) -> void:
	print(text)
	MassegeIn(str(text))

func MassegeIn(text : String) -> void:
	var p := {
		type = "msg",
		text = text,
		time = Time.get_unix_time_from_system(),
		stack = get_stack().slice(2, -1)
	}
	history.append(p)
	emit_signal("log_fired", p)
	QueueFlush()

func DebugMassege(text) -> void:
	if !text is String: text = str(text)
	if DEPUG: Massege(text)
	else: MassegeIn(text)

func QueueFlush() -> bool:
	if _fic: return false
	_fic = flush_intervnal
	call_deferred("IncFIC")
	return true

func IncFIC() -> void:
	_fic -= 1
	if _fic <= 0:
		_fic = 0
		Flush()
		return
	get_tree().create_timer(flush_intervnal / 60.0, false).connect("timeout", self, "IncFIC")

func Flush() -> void:
	var res : String
	for x in history:
		res += ParseLog(x)
	SU.SaveToFile(DataManger.GAMEDATAFOLDER().plus_file("current.log"), res)

func ParseLog(x : Dictionary) -> String:
	return "[%s] [%s] %s\n%s" % [Time.get_time_string_from_unix_time(x.time), x.type, x.text, ParseStack(x.stack)]

func ParseStack(s : Array) -> String:
	var r : String
	for x in s.size():
		r += "  %s - %s:%s:%s\n" % [x, s[x].source.get_file(), s[x].function, s[x].line]
	return r
