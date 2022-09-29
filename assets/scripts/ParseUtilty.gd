class_name ParseUtility

static func IsNum(i) -> bool: return i is float || i is int


static func CheckForBool(id : String, dic : Dictionary, tracer : String, d : Dictionary) -> bool:
	d.default = d.get("default", false)
	if !id in dic:
		Log.Error("The field \"%s\"  does not exist and should be set to a boolean " % [d.get("tracer_id", id)] + tracer)
		dic[id] = d.default
	elif !dic[id] is bool:
		Log.Error("The field \"%s\" should be set to a boolean " % [d.get("tracer_id", id)] + tracer)
		dic[id] = d.default
	return dic[id]

static func CheckForNumper(id : String, dic : Dictionary, tracer : String, d : Dictionary) -> float:
	d.default = d.get("default", 0)
	if !id in dic:
		Log.Error("The field \"%s\"  does not exist and should be set to a numper " % [d.trace_id] + tracer)
		dic[id] = d.default
	elif !IsNum(dic[id]):
		Log.Error("The field \"%s\" should be set to a numper " % [d.trace_id] + tracer)
		dic[id] = d.default
	return dic[id]

static func CheckForNumperPositive(id : String, dic : Dictionary, tracer : String, d : Dictionary) -> float:
	d.default = d.get("default", 0)
	CheckForNumper(id, dic, tracer, d)
	if dic[id] < 0:
		Log.Error("The field \"%s\" should be positive " % [d.trace_id] + tracer)
		dic[id] = d.default
	return dic[id]

static func CheckForNumperPositiveNonzero(id : String, dic : Dictionary, tracer : String, d : Dictionary) -> float:
	d.default = d.get("default", 1)
	CheckForNumper(id, dic, tracer, d)
	if dic[id] <= 0:
		Log.Error("The field \"%s\" should be positive non-zero " % [d.trace_id] + tracer)
		dic[id] = d.default
	return dic[id]

static func CheckForNumperPositiveNonzeroI(id : String, dic : Dictionary, tracer : String, d : Dictionary) -> float:
	d.default = d.get("default", 1)
	CheckForNumper(id, dic, tracer, d)
	if dic[id] < 1:
		Log.Error("The field \"%s\" should be more or equal to one" % [d.trace_id] + tracer)
		dic[id] = d.default
	return dic[id]

static func CheckForString(id : String, dic : Dictionary, tracer : String, d : Dictionary) -> String:
	var inputs : Array = d.get("inputs", [])
	var inputs_str : String
	if inputs:
		inputs_str += " and should be on of the following "
		for x in inputs.size():
			if x == inputs.size() - 1:
				inputs_str += " or "
			elif x:
				inputs_str += ", "
			inputs_str += "\"" + inputs[x] + "\""
	
	if !id in dic:
		Log.Error("The field \"%s\"  does not exist and should be set to a string%s " % [inputs_str, d.trace_id] + tracer)
		dic[id] = d.default
	elif !dic[id] is String || (inputs && !(dic[id].to_lower() if d.get("lower", true) else dic[id]) in inputs):
		Log.Error("The field \"%s\" should be set to a string%s " % [d.trace_id, inputs_str,] + tracer)
		dic[id] = d.default
	return dic[id]

static func CheckForEnum(id : String, dic : Dictionary, enum_p : Array, tracer : String, d : Dictionary) -> int:
	if !id in dic:
		Log.Error("The field \"%s\"  does not exist and should be set to a string%s " % [enum_p, d.trace_id] + tracer)
		dic[id] = d.default
	elif !dic[id] is String:
		Log.Error("The field \"%s\" should be set to a string%s " % [d.trace_id, enum_p] + tracer)
		dic[id] = d.default
	for i in enum_p.size():
		if !dic[id].matchn(enum_p[i]): continue
		return i
	Log.Error("The field \"%s\" should be set to a string%s " % [d.trace_id, enum_p] + tracer)
	return 0

static func CheckForDictionary(id : String, dic : Dictionary, tracer : String, d : Dictionary) -> Dictionary:
	if !id in dic:
		Log.Error("The field \"%s\"  does not exist and should be set to an object " % [d.get("tracer_id", id)] + tracer)
		dic[id] = d.default
	elif !dic[id] is Dictionary:
		Log.Error("The field \"%s\" should be set to an object " % [d.get("tracer_id", id)] + tracer)
		dic[id] = d.default
	return dic[id]

static func CheckValueList_Dictionary(id : int, dic : Array, tracer : String, d : Dictionary) -> int:
	if !dic[id] is Dictionary:
		Log.Error("The field \"%s\" should be set to an object " % [d.trace_id] + tracer)
		dic[id] = d.default
		return ERR_INVALID_PARAMETER
	return OK

static func CheckForArray(id : String, dic : Dictionary, tracer : String, d : Dictionary) -> Array:
	if !id in dic:
		Log.Error("The field \"%s\"  does not exist and should be set to an array " % [d.trace_id] + tracer)
		dic[id] = d.default
	elif !dic[id] is Array:
		Log.Error("The field \"%s\" should be set to an array " % [d.trace_id] + tracer)
		dic[id] = d.default
	return dic[id]



static func CheckForColor(id : String, dic : Dictionary, tracer : String, d : Dictionary) -> Color:
	var raw_c : Dictionary = CheckForDictionary(id, dic, tracer, d)
	return Color(
		CheckForNumperPositive("r", raw_c, tracer, Merge(d, {trace_id = AddKey(d.trace_id, "r")}, true)),
		CheckForNumperPositive("g", raw_c, tracer, Merge(d, {trace_id = AddKey(d.trace_id, "g")}, true)),
		CheckForNumperPositive("b", raw_c, tracer, Merge(d, {trace_id = AddKey(d.trace_id, "b")}, true)),
		d.get("a", 1) if "a" in d else (CheckForNumperPositive("a", raw_c, tracer, Merge(d, {trace_id = AddKey(d.trace_id, "a")}, true)) if "a" in raw_c else 1)
	)

static func CheckForGradient(id : String, dic : Dictionary, tracer : String, d : Dictionary) -> Gradient:
	if !id in dic:
		Log.Error("The field \"%s\"  does not exist and should be set to an object(gradient)" % [d.get("tracer_id", id)] + tracer)
		return d.default
	elif !dic[id] is Dictionary:
		Log.Error("The field \"%s\" should be set to an object(gradient) " % [d.get("tracer_id", id)] + tracer)
		return d.default
	var rq : RequestData = RequestData.new().Basic(tracer, d.get("trace_id", id))
	return ConstructGradient(dic[id], rq)

static func CheckForVector2(id : String, dic : Dictionary, tracer : String, d : Dictionary) -> Vector2:
	var def : Vector2 = d.get("default", Vector2())
	var raw_c : Dictionary = CheckForDictionary(id, dic, tracer, d)
	return Vector2(
		CheckForNumper("x", raw_c, tracer, Merge(d, {trace_id = AddKey(d.get("trace_id", id), "x"), default = def.x}, true)),
		CheckForNumper("y", raw_c, tracer, Merge(d, {trace_id = AddKey(d.get("trace_id", id), "y"), default = def.y}, true))
	)

static func CheckForRect(id : String, dic : Dictionary, tracer : String, d : Dictionary) -> Rect2:
	var raw_c : Dictionary = CheckForDictionary(id, dic, tracer, d)
	if "size" in raw_c:
		var size : float = CheckForNumper("size", raw_c, tracer, Merge(d, {trace_id = AddKey(d.trace_id, "size")}))
		return Rect2(
			CheckForNumper("x", raw_c, tracer, Merge(d, {trace_id = AddKey(d.trace_id, "x")}, true)),
			CheckForNumper("y", raw_c, tracer, Merge(d, {trace_id = AddKey(d.trace_id, "y")}, true)),
			size,
			size
		)
	return Rect2(
		CheckForNumper("x", raw_c, tracer, Merge(d, {trace_id = AddKey(d.trace_id, "x")}, true)),
		CheckForNumper("y", raw_c, tracer, Merge(d, {trace_id = AddKey(d.trace_id, "y")}, true)),
		CheckForNumper("w", raw_c, tracer, Merge(d, {trace_id = AddKey(d.trace_id, "w")}, true)),
		CheckForNumper("h", raw_c, tracer, Merge(d, {trace_id = AddKey(d.trace_id, "h")}, true))
	)

static func CheckForCurve(id : String, dic : Dictionary, tracer : String, d : Dictionary) -> Curve:
	if !id in dic:
		Log.Error("The field \"%s\"  does not exist and should be set to an Array(Curve)" % [d.get("id", id)] + tracer)
		return d.default
	elif !dic[id] is Array:
		Log.Error("The field \"%s\" should be set to an array(Curve) " % [d.get("id", id)] + tracer)
		return d.default
	var rq : RequestData = RequestData.new().Basic(tracer, d.get("id", id))
	var curve : = ValueCurve.new()
	
	for x in dic[id].size():
		if !dic[id][x] is Dictionary:
			Log.Error("The field \"%s\" should be set to a numper " % [d.get("id", id) + ".%s" % [x]] + tracer)
			continue
		var v : Vector2 = Vector2(
			CheckForNumperPositive("x", dic[id][x], tracer, Merge(d, {trace_id = AddKey(d.get("id", id), "x"), default = 0}, true)),
			CheckForNumper("y", dic[id][x], tracer, Merge(d, {trace_id = AddKey(d.get("id", id), "y"), default = 0}, true))
		)
		curve.setup_point(v.x,v.y)
	curve.apply_points()
	return curve



static func ConstructGradient(data : Dictionary, rq : RequestData) -> Gradient:
	var g : Gradient = Gradient.new()
	
	var offset_range : FloatingRange = FloatingRange.new(0, 1)
	
	# Removes Default points
	g.remove_point(0) # Start point
	g.remove_point(0) # End point
	
	CheckForArray("colors", data, rq.Tracer, rq.GetDict("colors"))
	
	var colors : Array = data.colors
	for x in colors.size():
		if !colors[x] is Dictionary:
			Log.Error("The field \"%s.colors.%s\" should be set to an object " % [rq.Id, x] + rq.Tracer)
			return null
		var p_col : Dictionary = colors[x]
		
		if "r" in p_col: CheckForNumperPositive("r", p_col, rq.Tracer, rq.GetDict(1,"colors.%s.r" % [x]))
		if "g" in p_col: CheckForNumperPositive("g", p_col, rq.Tracer, rq.GetDict(1,"colors.%s.g" % [x]))
		if "b" in p_col: CheckForNumperPositive("b", p_col, rq.Tracer, rq.GetDict(1,"colors.%s.b" % [x]))
		if "a" in p_col: CheckForNumperPositive("a", p_col, rq.Tracer, rq.GetDict(1,"colors.%s.a" % [x]))
		CheckForNumperPositive("offset", p_col, rq.Tracer, rq.GetDict("colors.%s.offset" % [x]))
		var offset : float = p_col.offset
		if !offset_range.InRange(offset): 
			Log.Warning("The field \"%s.colors.%s.offset\" is out of range wich is 0.0 - 1.0 " % [rq.Id, x] + rq.Tracer)
			offset = offset_range.Clamp(offset)
		
		g.add_point(offset, Color(p_col.get("r", 0),p_col.get("g", 0),p_col.get("b", 0),p_col.get("a", 1)))
	
	if "transition_type" in data: CheckForString("transition_type", data, rq.Tracer, rq.GetDict("transition_type"))
	var tr_str : String = data.get("transition_type", "linear")
	
	return g

static func Merge(d0 : Dictionary, d1 : Dictionary, over : bool = false) -> Dictionary:
	var d : Dictionary = d0.duplicate(true); d.merge(d1, over)
	return d

static func AddKey(s : String, k : String) -> String: return s + ("." if s else "") + k
