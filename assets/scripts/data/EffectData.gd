class_name EffectData extends BaseData


export var Speed : float
export var StartSpeed : float
export var TargetSpeed : float

export var Lifetime : float = 7

export var Graphics : Dictionary


export var BaseTexture : Texture

export var Hitbox : Shape2D
export var HitboxOffset : Vector2

func Tracer() -> String: return "in Effect(%s) at path \"%s\"" % [id, path]

func Build(data : Dictionary) -> void:
	.Build(data)
	var tracer : String = Tracer()
	if !"speed" in data:
		Log.Error("The field \"speed\" does not exist and should be set to a numper " + tracer)
		data.speed = 30
	elif !IsNum(data.speed):
		Log.Error("The field \"speed\" should be set to a numper " + tracer)
		data.speed = 30 
	Speed = data.speed
	
	if !"target_speed" in data:
		Log.Error("The field \"target_speed\" does not exist and should be set to a numper " + tracer)
		data.target_speed = 30
	elif !IsNum(data.target_speed):
		Log.Error("The field \"target_speed\" should be set to a numper " + tracer)
		data.target_speed = 30
	TargetSpeed = data.target_speed
	
	if !"lifetime" in data:
		data.lifetime = 10
	elif !IsNum(data.lifetime):
		Log.Warning("The field \"lifetime\" should be set to a numper" + tracer)
		data.lifetime = 10
	Lifetime = 10
	
	if !"graphics" in data:
		Log.Error("The field \"graphics\" does not exist and should be set to an object " + tracer)
		data.graphics = {}
	elif !data.graphics is Dictionary:
		Log.Error("The field \"graphics\" should be set to an object " + tracer)
		data.graphics = {}
	
	var graphics : Dictionary = data.graphics
	
	for x in graphics:
		if !graphics[x] is Dictionary:
			Log.Error("The field \"graphics.%s\" should be set to an object " % [x] + tracer)
			continue
		var g : Dictionary = graphics[x]
		
		Graphics[x] = DataManger.LoadGraphics(g, {id = "projectile(%s)" % id, subid = x, path = path})
	
#	CheckForDictionary("hitbox", data, tracer, {trace_id = "hitbox", default = {type = "cricle", radius = 4}})
#	var hitbox_data : Dictionary = data.hitbox
#
#	CheckForString("type", hitbox_data, tracer, {trace_id = "hitbox.type", default = "circle", inputs = ["circle", "rect", "box"], lower = true})
#	match hitbox_data.type.to_lower():
#		"circle":
#			Hitbox = CircleShape2D.new()
#			CheckForNumperPositiveNonzeroI("radius", hitbox_data, tracer, {trace_id = "hitbox.radius", default = 4})
#			Hitbox.radius = hitbox_data.radius
#		"rect":
#			Hitbox = CircleShape2D.new()
#			CheckForNumperPositiveNonzeroI("size_x", hitbox_data, tracer, {trace_id = "hitbox.size_x", default = 4})
#			CheckForNumperPositiveNonzeroI("size_y", hitbox_data, tracer, {trace_id = "hitbox.size_y", default = 4})
#			Hitbox.extents.x = hitbox_data.size_x
#			Hitbox.extents.y = hitbox_data.size_y
#		"box":
#			Hitbox = CircleShape2D.new()
#			CheckForNumperPositiveNonzeroI("size", hitbox_data, tracer, {trace_id = "hitbox.size", default = 4})
#			Hitbox.extents = hitbox_data.size * Vector2.ONE
#
#	if "offset" in hitbox_data:
#		CheckForDictionary("offset", hitbox_data, tracer, {trace_id = "hitbox.offset", default = {x = 0, y = 0}})
#		CheckForNumper("x", hitbox_data.offset, tracer,{trace_id = "hitbox.offset.x", default = 0})
#		CheckForNumper("y", hitbox_data.offset, tracer,{trace_id = "hitbox.offset.y", default = 0})
#		HitboxOffset.x = hitbox_data.offset.x
#		HitboxOffset.y = hitbox_data.offset.y
	
