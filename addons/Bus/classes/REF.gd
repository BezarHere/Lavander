class_name Ref extends Reference
signal ValueChanged(to)

var p_object : Object
var pointer : String
var value = null setget Set_Value
var value_type : int

var _locked : bool = false

func _init(o : Object, p : String) -> void:
	if !o:
		push_error("Invalid object")
		return
	pointer = p
	p_object = o
	value_type = typeof(p_object.get_indexed(pointer))
	value = p_object.get_indexed(pointer)

func Set_Value(to) -> void:
	if to == value || _locked: return
	value = to
	if !IsValid():
		push_error("Can't assign %s to %s.%s, Not valid" % [value, p_object, pointer])
		return
	UpdateValueType()
	value = convert(value, value_type)
	p_object.set_indexed(pointer, value)
	emit_signal("ValueChanged", to)

func UpdateValueType() -> void:
	if !IsValid(): return
	value_type = typeof(p_object.get_indexed(pointer))

func IsValid() -> bool: return p_object != null

func Lock() -> void: _locked = true
func Unlock() -> void: _locked = false

func _to_string() -> String: return "Ref(obj=%s,p=%s)" % [p_object, pointer]
