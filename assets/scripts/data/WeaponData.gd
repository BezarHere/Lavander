class_name WeaponData extends BaseData

enum {
	ACTIONTYPE_AUTO
	ACTIONTYPE_SEMIAUTO
}

export var ProjectileRaw : Dictionary

export var Firerate : float
export var Cooldown : float # AutoSet

export var BurstCount : int
export var BurstDelay : float

export var ActionType : int

export var Nuzzle : Vector2
export var NuzzleTangent : float # Offset for double fire 
export var AlternateFire : bool

var projectile_data : ProjectileData = ProjectileData.new()
export var ProjectilePrototype : PackedScene
export var NFEPrototype : PackedScene

func Build(data : Dictionary) -> void:
	.Build(data)
	var tracer : String = "in Weapon(%s) at path \"%s\"" % [id, path]
	data = DataManger.CheckCopy(data, tracer)
	
	ParseUtility.CheckForDictionary("projectile", data, tracer, {trace_id = "projectile", default = {}})
	ProjectileRaw = data.projectile
	 
	ParseUtility.CheckForNumperPositiveNonzero("firerate", data, tracer, {trace_id = "firerate", default = 1.0})
	Firerate = data.firerate
	Cooldown = 1.0 / SAFE(Firerate)
	
	if "burst_count" in data: ParseUtility.CheckForNumperPositiveNonzeroI("burst_count", data, tracer, {trace_id = "burst_count", default = 1})
	BurstCount = data.get("burst_count", 1)
	
	if "burst_delay" in data: ParseUtility.CheckForNumperPositive("burst_delay", data, tracer, {trace_id = "burst_delay", default = 0.2})
	BurstDelay = data.get("burst_delay", 0.1)
	
	if "action_type" in data: ParseUtility.CheckForString("action_type", data, tracer, {trace_id = "action_type", default = "auto", inputs = ["auto", "semi-auto"], lower = true})
	match data.action_type:
		"auto": ActionType = 0
		"semi-auto": ActionType = 1
	
	projectile_data.id = id + ".projectile"
	projectile_data.path = path
	projectile_data.mod = mod
	projectile_data.Construct(ProjectileRaw)
	
	var p := Projectile.new()
	p.data = projectile_data
	p.id = id + ".projectile"
	p.Construct()
	
	ProjectilePrototype = SU.PackNode(p)
	
	if "fire_effect" in data:
		var nfe : Dictionary = ParseUtility.CheckForDictionary("fire_effect", data, tracer, {trace_id = "fire_effect", default = {}})
		var e : NuzzleFireEffect = DataManger.AvailableNFEs.get(
			ParseUtility.CheckForString(
				"instance_type", nfe, tracer,
				{trace_id = "fire_effect.instance_type", default = "spark", inputs = DataManger.AvailableNFEs.keys()}
			)
		).new()
		e.id = ParseUtility.AddKey(id, "fire_effect")
		e.path = path
		e.Build(nfe)
		
		NFEPrototype = SU.PackNode(e)
		e.kill()
	if Log.DEPUG: Log.Massege("NFE(%s): %s" % [id, NFEPrototype])
	

func DPS() -> float:
	if !projectile_data: return 0.0
	return projectile_data.Damage_Amount * AvergeFirerate()

func AvergeFirerate() -> float: return (Firerate * BurstCount) - (BurstDelay * BurstCount)
