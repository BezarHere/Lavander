class_name SingleEffect extends Sprite

var tracer : String
var tracker : Dictionary # Needs path, subid and id

func Build(data : Dictionary) -> void:
	ParseUtility.CheckForDictionary("animation", data, tracer, {default = {}})
	texture = DataManger.LoadGraphics(data.animation, tracker)
	
	
