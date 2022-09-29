class_name RefLinks extends Reference
const MAX_OUTPOTS = 127

var _Input : Ref setget Set_Input
var  _Outpots : Array

func _init(ref : Ref = null, refs : Array = []) -> void:
	Set_Input(ref)
	for x in refs:
		AddOutpot(x)

func Set_Input(to : Ref) -> void:
	if to == _Input: return
	
	if _Input and _Input is Ref:
		_Input.disconnect("ValueChanged" , self, "InputValueChanged")
	
	if !to:
		_Input = null
		return
	
	if !to.IsValid():
		_Input = null
		return
	
	_Input = to
#	if !to.is_connected("ValueChanged", self, "InputValueChanged"):
	_Input.connect("ValueChanged", self, "InputValueChanged", [])

func InputValueChanged(to) -> void:
	for x in _Outpots:
		if x && x is Ref:
			x.value = to
			continue
		_Outpots.erase(x)

func AddOutpot(outpot : Ref) -> bool:
	if _Outpots.size() >= MAX_OUTPOTS:
		_Outpots.resize(MAX_OUTPOTS)
		return false
	if !outpot: return false
	if !outpot.IsValid(): return false
	_Outpots.append(outpot)
	return true

func RemoveOutpots_AllConnected2(obj : Object, method : String) -> void:
	for x in _Outpots:
		if x && x is Ref:
			if x.p_object == obj && x.pointer == method: _Outpots.erase(x)
			continue
		_Outpots.erase(x)

# Only removes the frist one.
func RemoveOutpots_Connected2(obj : Object, method : String) -> void:
	for x in _Outpots:
		if x && x is Ref:
			if x.p_object == obj && x.pointer == method:
				_Outpots.erase(x)
				return
			continue
		_Outpots.erase(x)
