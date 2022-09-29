class_name ProjectileData extends BaseData

const DAMAGE_TYPES_NAMES = [
	"kineatic", "energy", "thermal"
]

export var Speed : float
export var StartSpeed : float
export var TargetSpeed : float

export var Lifetime : float = 7

export var Graphics : Dictionary
export var Polygons : Dictionary

export var Damage_Type : int
export var Damage_Amount : int
export var Damage_Variation : float = 0.0

export var BaseTexture : Texture

export var Hitbox : Shape2D
export var HitboxOffset : Vector2

export var MovingEase : int = Tween.EASE_IN_OUT
export var MovingTransition : int = Tween.TRANS_LINEAR

func Build(data : Dictionary) -> void:
	.Build(data)
	var tracer : String = "in Projectile(%s) at path \"%s\"" % [id, path]
	data = DataManger.CheckCopy(data, tracer)
	
	
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
	
	if !"damage" in data:
		Log.Error("The field \"damage\" does not exist and should be set to an object " + tracer)
		data.damage = {}
	elif !data.damage is Dictionary:
		Log.Error("The field \"damage\" should be set to an object " + tracer)
		data.damage = {}
	var damage : Dictionary = data.damage
	
	if !"type" in damage:
		Log.Error("The field \"damage.type\" does not exist and should be set to a string " + tracer)
		data.damage.type = "kineatic"
	elif !damage.type is String:
		Log.Error("The field \"damage.type\" should be set to a string, a string of any \"kineatic\", \"energy\" or \"thermal\" case insensetive " + tracer)
		data.damage.type = "kineatic"
	elif !damage.type.to_lower() in DAMAGE_TYPES_NAMES:
		Log.Error("The field \"damage.type\" should be set to a string of any \"kineatic\", \"energy\" or \"thermal\" case insensetive " + tracer)
		damage.type = "kineatic"
	Damage_Type = DAMAGE_TYPES_NAMES.find(damage.type)
	if Damage_Type <= -1: Damage_Type = 0
	
	if !"amount" in damage:
		Log.Error("The field \"damage.amount\" does not exist and should be set to a num " + tracer)
		damage.amount = 1
	elif !IsNum(damage.amount):
		Log.Error("The field \"damage.amount\" should be set to a numper " + tracer)
		damage.amount = 1
	
	if !"amount_variation" in damage:
#		Log.Error("The field \"damage.amount_variation\" does not exist and should be set to a numoer " + tracer)
		damage.amount_variation = 0
	elif !IsNum(damage.amount_variation):
		Log.Warning("The field \"damage.amount_variation\" should be set to a numper" + tracer)
		damage.amount_variation = 0
	damage.amount_variation = abs(damage.amount_variation)
	
	Damage_Amount = damage.amount
	Damage_Variation = damage.amount_variation
	
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
		var poly : Polygon2D = DataManger.ParseIfPolygon(g, {link = tracer, id = "graphics.%s" % x, path = path, nod = mod})
		if poly:
			Polygons[x] = SU.PackNode(poly)
			continue
		
		Graphics[x] = DataManger.LoadGraphics(g, {id = "projectile(%s)" % id, subid = x, path = path})
		
		
	
	ParseUtility.CheckForDictionary("hitbox", data, tracer, {trace_id = "hitbox", default = {type = "cricle", radius = 4}})
	var hitbox_data : Dictionary = data.hitbox
	
	ParseUtility.CheckForString("type", hitbox_data, tracer, {trace_id = "hitbox.type", default = "circle", inputs = ["circle", "rect", "box"], lower = true})
	match hitbox_data.type.to_lower():
		"circle":
			Hitbox = CircleShape2D.new()
			ParseUtility.CheckForNumperPositiveNonzeroI("radius", hitbox_data, tracer, {trace_id = "hitbox.radius", default = 4})
			Hitbox.radius = hitbox_data.radius
		"rect":
			Hitbox = CircleShape2D.new()
			ParseUtility.CheckForNumperPositiveNonzeroI("size_x", hitbox_data, tracer, {trace_id = "hitbox.size_x", default = 4})
			ParseUtility.CheckForNumperPositiveNonzeroI("size_y", hitbox_data, tracer, {trace_id = "hitbox.size_y", default = 4})
			Hitbox.extents.x = hitbox_data.size_x
			Hitbox.extents.y = hitbox_data.size_y
		"box":
			Hitbox = CircleShape2D.new()
			ParseUtility.CheckForNumperPositiveNonzeroI("size", hitbox_data, tracer, {trace_id = "hitbox.size", default = 4})
			Hitbox.extents = hitbox_data.size * Vector2.ONE
	
	if "offset" in hitbox_data:
		ParseUtility.CheckForDictionary("offset", hitbox_data, tracer, {trace_id = "hitbox.offset", default = {x = 0, y = 0}})
		ParseUtility.CheckForNumper("x", hitbox_data.offset, tracer,{trace_id = "hitbox.offset.x", default = 0})
		ParseUtility.CheckForNumper("y", hitbox_data.offset, tracer,{trace_id = "hitbox.offset.y", default = 0})
		HitboxOffset.x = hitbox_data.offset.x
		HitboxOffset.y = hitbox_data.offset.y
	

# Might be false
func TravelRange(time : float = 1.0) -> float: return time * lerp(StartSpeed, TargetSpeed, clamp(Speed / SAFE(TargetSpeed - StartSpeed), 0, 1))

