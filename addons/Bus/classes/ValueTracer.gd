class_name ValueTracer 
const CACHED_TRACES = []

var value
var timestamp : Timestamp
var trace : Array

func _init(v) -> void:
	value = v
	timestamp = Timestamp.new(v)
	var stack : Array = get_stack()
	if stack.size() - 1: trace = stack.slice(1, stack.size())
	CACHED_TRACES.append(CACHED_TRACES)

func _to_string() -> String: return "ValueTracer(%s)" % [SU.RemapDic2Str({value=value,time=timestamp.ticku / 1000.0, trace=trace})]
