class_name LoadedTexture extends ImageTexture

var path : String
var id : String
var subid : String

var override_size : bool = false
var size_override : Vector2

var scale : float
var offset : Vector2

var image : Image

func _init(img : Image = null, f : int = 1, rect := Rect2(-1,-1,0,0)) -> void:
	if !img: return
	if rect.position.x == -1 || rect.position.y == -1:
		rect.size = img.get_size()
		rect.position = Vector2.ZERO
	image = img.get_rect(rect)
	create_from_image(image, f)
	

func Data() -> Dictionary:
	var da : PoolByteArray = image.data.data
	var das : int = da.size()
	da = da.compress(2)
	return {
		type = "blit",
		path = path,
		override_size = override_size,
		size_override_x = size_override.x,
		size_override_y = size_override.y,
		scale = scale,
		offset_x = offset.x,
		offset_y = offset.y,
		f = flags,
		png = {
			w = image.get_width(),
			h = image.get_height(),
			f = image.get_format(),
			m = image.data.mipmaps,
			p = Array(da),
			ps2 = da.size(),
			ps = das
		}
	}

func Recompile(data : Dictionary) -> LoadedTexture:
	path = data.path
	override_size = data.override_size
	size_override.x = data.size_override_x
	size_override.y = data.size_override_y
	scale = data.scale
	offset.x = data.offset_x
	offset.y = data.offset_y
	image = Image.new()
	image.create_from_data(
		data.png.w, data.png.h, data.png.m, data.png.f, PoolByteArray(data.png.p).decompress(data.png.ps, 2)
	)
	create_from_image(image, data.f)
	return self
