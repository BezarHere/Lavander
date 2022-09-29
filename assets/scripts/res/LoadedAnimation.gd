class_name LoadedAnimation extends AnimatedTexture


var path : String
var id : String
var subid : String

var override_size : bool = false
var size_override : Vector2

var scale : float
var offset : Vector2


func Data() -> Dictionary: return {
	path = path,
	override_size = override_size,
	size_override_x = size_override.x,
	size_override_y = size_override.y,
	scale = scale,
	offset_x = offset.x,
	offset_y = offset.y,
}

