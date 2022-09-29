class_name EntityData extends BaseData


export var MaxHealth : int

export var Speed : float = 30
export var MaxSpeed : float = 100

export var Multiplaiers : Dictionary


export var Resistance : Dictionary

export var Graphics : Dictionary
var Weapon : WeaponData
export var WeaponPrototype : PackedScene

export var HitBoxes : Array

export var WeaponTags : Array

export var HudOffset : Vector2

export var hidden : bool

func Build(data : Dictionary) -> void:
	.Build(data)
	var tracer : String = "in Entity(%s) at path \"%s\"" % [id, path]
	data = DataManger.CheckCopy(data, tracer)
	
	if "hidden" in data: hidden = ParseUtility.CheckForBool("hidden", data, tracer, {default = true})
	
	ParseUtility.CheckForNumper("speed", data, tracer, {trace_id = "speed", default = 30})
	Speed = data.speed
	
	ParseUtility.CheckForNumper("max_speed", data, tracer, {trace_id = "max_speed", default = 100})
	MaxSpeed = data.max_speed
	
	ParseUtility.CheckForNumper("health", data, tracer, {trace_id = "health", default = 70})
	MaxHealth = data.health
	
	ParseUtility.CheckForDictionary("graphics", data, tracer, {trace_id = "graphics", default = {}})
	
	for x in data.graphics:
		Graphics[x] = DataManger.LoadGraphics(data.graphics[x], {id = id, subid = x, mod = mod, path = path})
#		Graphics[x].subtex.get_data().save_png("res://test.png")
	
	if "weapon" in data:
		var weapons : Dictionary = ParseUtility.CheckForDictionary("weapon", data, tracer, {trace_id = "weapon", default = {tags = "u", default = ""}})
#		var default : String
#		if "default" in weapons: default = ParseUtility.CheckForString("default", weapons, tracer, {trace_id = "weapon.default", default = ""})
#		if default: DefaultWeaponPrototype = DataManger.Weapons[default]
#		WeaponTags = ParseUtility.CheckForArray("tags", weapons, tracer, {trace_id = "weapon.tags", default = []})
		Weapon = WeaponData.new()
		Weapon.mod = data["#mod"]
		Weapon.path = data["#path"]
		Weapon.id = data["#id"] + ".weapon"
		Weapon.Construct(weapons)
		
		var b := BaseWeapon.new()
		b.id = Weapon.id
		b.data = Weapon
		b.Construct()
		
		WeaponPrototype = SU.PackNode(b)
		
	
	
	if "hitbox" in data:
		ParseUtility.CheckForDictionary("hitbox", data, tracer, {trace_id = "hitbox", default = {type = "circle", radius = 16}})
		var hitbox_data : Dictionary = data.hitbox
		var hitbox : Shape2D
		var offset : Vector2
		var is_poly : bool
		var poly : PoolVector2Array
		
		ParseUtility.CheckForString("type", hitbox_data, tracer, {trace_id = "hitbox.type", default = "circle", inputs = ["circle", "rect", "box", "tringle"], lower = true})
		match hitbox_data.type.to_lower():
			"circle":
				hitbox = CircleShape2D.new()
				ParseUtility.CheckForNumperPositiveNonzeroI("radius", hitbox_data, tracer, {trace_id = "hitbox.radius", default = 4})
				hitbox.radius = hitbox_data.radius
			"rect":
				hitbox = CircleShape2D.new()
				ParseUtility.CheckForNumperPositiveNonzeroI("size_x", hitbox_data, tracer, {trace_id = "hitbox.size_x", default = 4})
				ParseUtility.CheckForNumperPositiveNonzeroI("size_y", hitbox_data, tracer, {trace_id = "hitbox.size_y", default = 4})
				hitbox.extents.x = hitbox_data.size_x
				hitbox.extents.y = hitbox_data.size_y
			"box":
				hitbox = CircleShape2D.new()
				ParseUtility.CheckForNumperPositiveNonzeroI("size", hitbox_data, tracer, {trace_id = "hitbox.size", default = 4})
				hitbox.extents = hitbox_data.size * Vector2.ONE
			"tringle":
				is_poly = true
				ParseUtility.CheckForNumperPositiveNonzeroI("hight", hitbox_data, tracer, {trace_id = "hitbox.hight", default = 4})
				ParseUtility.CheckForNumperPositiveNonzeroI("base", hitbox_data, tracer, {trace_id = "hitbox.base", default = 4})
				poly = PoolVector2Array([
					Vector2(0, -hitbox_data.hight/2.0),
					Vector2(-hitbox_data.base/2.0, hitbox_data.hight/2.0),
					Vector2(hitbox_data.base/2.0, hitbox_data.hight/2.0),
				])
		
		if "offset" in hitbox_data:
			ParseUtility.CheckForDictionary("offset", hitbox_data, tracer, {trace_id = "hitbox.offset", default = {x = 0, y = 0}})
			ParseUtility.CheckForNumper("x", hitbox_data.offset, tracer,{trace_id = "hitbox.offset.x", default = 0})
			ParseUtility.CheckForNumper("y", hitbox_data.offset, tracer,{trace_id = "hitbox.offset.y", default = 0})
			offset.x = hitbox_data.offset.x
			offset.y = hitbox_data.offset.y
		
		HitBoxes.append({shape = hitbox, offset = offset, is_poly = is_poly, poly = poly})
	
	
	if "hitboxes" in data:
		ParseUtility.CheckForArray("hitboxes", data, tracer, {trace_id = "hitboxes", default = []})
		var hitbox_list : Array = data.hitboxes
		
		for i in hitbox_list.size():
			if ParseUtility.CheckValueList_Dictionary(i, hitbox_list, tracer, {trace_id = "hitboxes.%s" % i, default = {type = "circle", radius = {x = 0, y = 0}}}): continue
			var hitbox_data : Dictionary = hitbox_list[i]
			ParseUtility.CheckForString("type", hitbox_data, tracer, {trace_id = "hitboxes.%s.type" % i, default = "circle", inputs = ["circle", "rect", "box", "tringle"], lower = true})
			var hitbox : Shape2D
			var offset : Vector2
			var is_poly : bool
			var poly : PoolVector2Array
			
			match hitbox_data.type.to_lower():
				"circle":
					hitbox = CircleShape2D.new()
					ParseUtility.CheckForNumperPositiveNonzeroI("radius", hitbox_data, tracer, {trace_id = "hitboxes.%s.radius" % i, default = 4})
					hitbox.radius = hitbox_data.radius
				"rect":
					hitbox = CircleShape2D.new()
					ParseUtility.CheckForNumperPositiveNonzeroI("size_x", hitbox_data, tracer, {trace_id = "hitbox.%s.size_x" % i, default = 4})
					ParseUtility.CheckForNumperPositiveNonzeroI("size_y", hitbox_data, tracer, {trace_id = "hitboxes.%s.size_y" % i, default = 4})
					hitbox.extents.x = hitbox_data.size_x
					hitbox.extents.y = hitbox_data.size_y
				"box":
					hitbox = CircleShape2D.new()
					ParseUtility.CheckForNumperPositiveNonzeroI("size", hitbox_data, tracer, {trace_id = "hitboxes.%s.size" % i, default = 4})
					hitbox.extents = hitbox_data.size * Vector2.ONE
				"tringle":
					is_poly = true
					ParseUtility.CheckForNumperPositiveNonzeroI("hight", hitbox_data, tracer, {trace_id = "hitbox.hight", default = 4})
					ParseUtility.CheckForNumperPositiveNonzeroI("base", hitbox_data, tracer, {trace_id = "hitbox.base", default = 4})
					poly = PoolVector2Array([
						Vector2(0, -hitbox_data.hight/2.0),
						Vector2(-hitbox_data.base/2.0, hitbox_data.hight/2.0),
						Vector2(hitbox_data.base/2.0, hitbox_data.hight/2.0),
					])
			
			if "offset" in hitbox_data:
				ParseUtility.CheckForDictionary("offset", hitbox_data, tracer, {trace_id = "hitboxes.%s.offset" % i, default = {x = 0, y = 0}})
				ParseUtility.CheckForNumper("x", hitbox_data.offset, tracer,{trace_id = "hitboxes.%s.offset.x" % i, default = 0})
				ParseUtility.CheckForNumper("y", hitbox_data.offset, tracer,{trace_id = "hitboxes.%s.offset.y" % i, default = 0})
				offset.x = hitbox_data.offset.x
				offset.y = hitbox_data.offset.y
			HitBoxes.append({shape = hitbox, offset = offset, is_poly = is_poly, poly = poly})
	
	if !HitBoxes: Log.Warning("No HITBOXES set " + tracer)
	
	if "hud" in data:
		var hud_data : Dictionary = ParseUtility.CheckForDictionary("hud", data, tracer, {default = {}})
		if "offset" in hud_data: HudOffset = ParseUtility.CheckForVector2("offset", hud_data, tracer, {trace_id = "hud.offset", default = Vector2(0, 96)})
		
	

func Defaults() -> Dictionary:
	var res : Dictionary = .Defaults()
#	for x in DataActions:
#		res[x] = DataActions[x].get("default", VT_DEF[DataActions[x].type])
	return res


func MoldData(id : String, value): return value
#	if id in DataActions:
#		var ac : Dictionary = DataActions[id]
#		value = ApplyRules(id, value, ac)
#	return value


func Power(type : int) -> float:
	match type:
		0: return sqrt(MaxSpeed * Speed)
		1: return MaxHealth as float
		2: 
			if Weapon:
				return Weapon.DPS()
	return 0.0

func Icon() -> Texture: return Graphics.get("icon", Graphics.get("base", DataManger.DEFAULT_RAW))
