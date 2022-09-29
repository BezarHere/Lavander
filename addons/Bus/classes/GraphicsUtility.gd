class_name GU extends ObjectStructure
const STATICS_VARS = {} # Static varibles

static func BuildAnimatedTexture(frames : Array, fps : int) -> AnimatedTexture:
	var b : AnimatedTexture = AnimatedTexture.new()
	b.frames = frames.size()
	for x in b.frames:
		if !frames[x] as Texture:
			Exception.UnexpectedNull("frames[%s]" % [x])
			continue
		b.set_frame_texture(x, frames[x])
	b.fps = abs(fps)
	return b

static func BuildSpriteFrames_AnimatedTextrues(textures : Dictionary) -> SpriteFrames:
	var list : Dictionary
	var data : Dictionary
	
	for x in textures:
		var text : AnimatedTexture = textures[x]
		if !text:
			Exception.UnexpectedNull("textures[%s]" % [x])
			continue
		list[x] = []
		data[x] = {
			speed = text.fps,
			loop = !text.oneshot
		}
		for i in text.frames:
			list[x].append(text.get_frame_texture(i))
	
	return BuildSpriteFrames(list, data)


static func BuildSpriteFrames(textures : Dictionary, data : Dictionary = {}) -> SpriteFrames:
	var b : SpriteFrames = SpriteFrames.new()
	for x in textures:
		if !textures[x] is Array:
			Exception.InvalidType("textures[%s]"  % [x], SU.TypeName(textures[x]), "array")
			continue
		var sub_data : Dictionary = data.get(x, {})
		b.add_animation(x)
		for i in textures[x].size():
			if !textures[x][i] is Texture:
				Exception.InvalidType("textures[%s][%s]" % [x,i], SU.TypeName(textures[x][i]), "texture")
				continue
			b.add_frame(x, textures[x][i])
			for j in int(textures[x][i].get_frame_delay(x) / sub_data.get("speed", 5)):
				b.add_frame(x, textures[x][i])
		b.set_animation_loop(x, sub_data.get("loop", false))
		b.set_animation_speed(x, sub_data.get("speed", 5))
	return b

static func CurveAnimatedTexture_Set(curve : Curve, text : AnimatedTexture, value : float = 1.0) -> void:
	if !text:
		Exception.UnexpectedNull("text")
		return
	if !curve:
		Exception.UnexpectedNull("curve")
		return
	if !text.frames:
		Exception.Threw("text.frames", Exception.ERR_PR_REQ_POSITIVE)
		return
	var ratio : float = 1.0 / (text.frames - 1)
	for x in text.frames:
		text.set_frame_delay(x, curve.interpolate(ratio * x) * value)


static func CurveAnimatedTexture_Add(curve : Curve, text : AnimatedTexture) -> void:
	if !text:
		Exception.UnexpectedNull("text")
		return
	if !curve:
		Exception.UnexpectedNull("curve")
		return
	if !text.frames:
		Exception.Threw("text.frames", Exception.ERR_PR_REQ_POSITIVE)
		return
	var ratio : float = 1.0 / (text.frames - 1)
	for x in text.frames:
		text.set_frame_delay(x, curve.interpolate(ratio * x) + text.get_frame_delay(x))

static func CurveAnimatedTexture_Mul(curve : Curve, text : AnimatedTexture) -> void:
	if !text:
		Exception.UnexpectedNull("text")
		return
	if !curve:
		Exception.UnexpectedNull("curve")
		return
	if !text.frames:
		Exception.Threw("text.frames", Exception.ERR_PR_REQ_POSITIVE)
		return
	var ratio : float = 1.0 / (text.frames - 1)
	for x in text.frames:
		text.set_frame_delay(x, curve.interpolate(ratio * x) * text.get_frame_delay(x))


static func CurveAnimatedTexture_Div(curve : Curve, text : AnimatedTexture) -> void:
	if !text:
		Exception.UnexpectedNull("text")
		return
	if !curve:
		Exception.UnexpectedNull("curve")
		return
	if !text.frames:
		Exception.Threw("text.frames", Exception.ERR_PR_REQ_POSITIVE)
		return
	var ratio : float = 1.0 / (text.frames - 1)
	for x in text.frames:
		text.set_frame_delay(x, curve.interpolate(ratio * x) / text.get_frame_delay(x))

static func BuildImageTexture(image : Image, flags : int = 1) -> ImageTexture:
	var t : ImageTexture = ImageTexture.new()
	t.create_from_image(image, flags)
	return t


static func BuildAtlasTexture(tex : Texture, rect : Rect2,flags : int = 1) -> AtlasTexture:
	var t : AtlasTexture = AtlasTexture.new()
	t.atlas = tex
	t.region = rect
	t.flags = flags
	return t
