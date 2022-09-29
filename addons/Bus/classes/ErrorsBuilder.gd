class_name ErrorsBuilder extends Resource
signal BasicLog

enum {
	MASSEGE, INFO, ANNONCMENT,
	WARNNING, ERROR, FATELERROR
}

export var _error_masseges : Array
export var _error_ticks : Array
export var _error_types : Array
export var _error_params : Array
export var _error_id : Array
export var _error_stacks : Array

export var _cache : Dictionary

export var SkipedStackSections : int = 2

var _EmitBasicLog : bool = true

func Append(msg : String, type : int = WARNNING) -> int: return Append_Adv(msg, type, "_", {})
func Append_Params(msg : String, type : int = WARNNING, params : Dictionary = {}) -> int: return Append_Adv(msg, type, "_", params)

func Append_Adv(msg : String, type : int, id : String, params : Dictionary) -> int:
	_error_masseges.append(msg)
	_error_types.append(type)
	_error_ticks.append(OS.get_ticks_msec())
	_error_params.append(params)
	_error_id.append(id)
	_error_stacks.append(get_stack())
	emit_changed()
	if _EmitBasicLog: emit_signal("BasicLog", msg, type)
	return _error_masseges.size() - 1

func Clear(cach : bool = true) -> void:
	if cach:
		_cache[OS.get_ticks_msec()] = {
			masseges = _error_masseges.duplicate(true),
			ticks = _error_ticks.duplicate(true),
			types = _error_types.duplicate(true),
			params = _error_params.duplicate(true),
			id = _error_id.duplicate(true),
			stacks = _error_stacks.duplicate(true),
		}
	_error_masseges.clear()
	_error_ticks.clear()
	_error_types.clear()
	_error_params.clear()
	_error_id.clear()
	_error_stacks.clear()
	emit_changed()

func _to_string() -> String:
	var t : String
	
	for x in _error_masseges.size():
		t += Error2String(
			_error_masseges[x],
			_error_types[x],
			_error_id[x],
			_error_params[x],
			_error_ticks[x],
			ResizeStack(_error_stacks[x], SkipedStackSections)
		) + "\n"
	
	return t

func Log2Text(offset : int = 0, params_enabled : bool = true) -> String:
	if _error_masseges.empty() or _error_masseges.size() <= offset or -_error_masseges.size() > offset: return "0 [null] null"
	
	return Error2String(
		_error_masseges[offset],
		_error_types[offset],
		_error_id[offset],
		_error_params[offset] if params_enabled else {},
		_error_ticks[offset],
		ResizeStack(_error_stacks[offset], SkipedStackSections)
	)

static func Error2String(msg : String, type : int, id : String, params : Dictionary, tick : int, stack : Array) -> String:
	var t : String = "%s%s" % [tick, " ".repeat( 8 - str(tick).length() )]
	match type:
		MASSEGE:
			t += "[massege]"
		INFO:
			t += "[info]"
		ANNONCMENT:
			t += "[annoncment]"
		WARNNING:
			t += "[warnning]"
		ERROR:
			t += "[error]"
		FATELERROR:
			t += "[crash]"
		_:
			t += "[pior%s]" % type
	
	t = Utils.StretchString(t, 18)
	
	t += msg
	
	for x in stack.size():
		t += "\n   %s at %s:%s.%s" % [x + 1, stack[x].source.get_basename().get_file(), stack[x].function, stack[x].line]
	
	if params:
		t += "\n  @Params:"
		for x in params:
			t += "\n      %s: %s" % [x, params[x]]
	
	
	if id and id != "_":
		t += "\n  @ID: %s" % [id]
	
	
	return t

static func ResizeStack(stack : Array, offset : int) -> Array:
	if stack.size() - offset <= 0: return []
	for x in offset:
		stack.remove(0)
	return stack
