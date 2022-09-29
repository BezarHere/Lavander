class_name RequestData

var InitStack : Array
var Path : String
var Id : String
var Subid : String
var Mod : String
var Inputs : PoolStringArray
var Tracer : String

func _init() -> void: InitStack = get_stack()
func Basic(tracer : String, id : String) -> RequestData:
	Id = id; Tracer = tracer; return self

func GetDict(def, sub_id : String = "") -> Dictionary: return {trace_id = Id + (("." + sub_id) if sub_id else ""), inputs = Inputs, default = def}
