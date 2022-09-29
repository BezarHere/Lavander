class_name AtlasImage extends Image

class ImageCursor:
	
	func _init(_x : int, _y : int, _w : int, _h : int, _img : Image = null) -> void:
		x = _x;y=_y;w=_w;h=_h;img=_img
	
	var x : int; var y : int; var w : int; var h : int; var img : Image
	
	func Rect2() -> Rect2: return Rect2(x,y,w,h)
	func position() -> Vector2: return Vector2(x,y)
	func size() -> Vector2: return Vector2(w,h)
	func _to_string() -> String: return "ImageCursor%s" % [Rect2()]

var images : Array

func AddImage(x : int, y : int, img : Image) -> void:
	images.append(ImageCursor.new(
		x,y,
		img.get_width(), img.get_height(),
		img)
	)
