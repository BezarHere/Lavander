"""
Just a sup class for handling custom classes
I don't want the main and mostly used class to be errored if any custom classes it ref to get errored

TL;DR Safe fail for ParseUtility

"""

class_name ParseConstruct extends ParseUtility

static func ConstructCost(id : String, dic : Dictionary, tracer : String, d : Dictionary) -> Cost:
	var cost := Cost.new()
	var data : Dictionary = CheckForDictionary(id, dic, tracer, d)
	if "photons" in data: cost.Photons = CheckForNumperPositive("photons", data, tracer, Merge(d, {trace_id = AddKey(d.get("trace_id", ""), "photons")}, true))
	if "star_dust" in data: cost.StarDust = CheckForNumperPositive("star_dust", data, tracer, Merge(d, {trace_id = AddKey(d.get("trace_id", ""), "star_dust")}, true))
	if "xp" in data: cost.Xp = CheckForNumperPositive("xp", data, tracer, Merge(d, {trace_id = AddKey(d.get("trace_id", ""), "xp")}, true))
	return cost

