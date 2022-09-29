class_name Struct 

var __init
func _init(x = null) -> void:
	__init = x
	Init(x)

func Init(x) -> void:
	pass 

func New() -> Struct:
	var x : Struct = get_script().new(__init)
	return x
