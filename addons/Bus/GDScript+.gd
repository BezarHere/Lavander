class_name GDScriptP extends GDScript

func _to_string() -> String: return "Script(%s)" % SU.RemapArr2Str(get_property_list())
