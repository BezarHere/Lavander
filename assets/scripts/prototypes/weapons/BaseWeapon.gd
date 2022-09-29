class_name BaseWeapon extends Node2D

export var id : String

export var BulletPrototype : PackedScene

var data : WeaponData

var CustomData : ObjectTweaks = ObjectTweaks.new()

var CooldwonTimer : Timer

export var Nodes : Dictionary
export var HasLoaded : bool

export var Team : int

var IsCoolingDown : bool

var TriggerPulled : bool

func _ready() -> void:
	Construct()

func Construct() -> void:
	if HasLoaded:
		data = Game.WeaponsBank[id][0]
		CustomData = Game.WeaponsBank[id][1]
		LoadData()
	else:
		Game.WeaponsBank[id] = [data, CustomData]
		BuildData()
		HasLoaded = true

func LoadData() -> void:
	
	
	LoadNodes()

func LoadNodes() -> void:
	CooldwonTimer = ExtractNode("col_timer")

func BuildData() -> void:
	BulletPrototype = data.ProjectilePrototype
	
	BuildNodes()
	HasLoaded = true

func BuildNodes() -> void:
	CooldwonTimer = Timer.new()
	CooldwonTimer.wait_time = data.Cooldown
	CooldwonTimer.autostart = false
	CooldwonTimer.one_shot = true
	CooldwonTimer.connect("timeout", self, "CooldownDone", [], CONNECT_PERSIST)
	add_child(CooldwonTimer)
	
	RegisterNode(CooldwonTimer, "col_timer")

func RegisterNode(node : Node, id : String) -> void:
	node.name = id
	node.owner = self
	Nodes[id] = self.get_path_to(node)

func ExtractNode(id : String) -> Node: return get_node(Nodes[id])

func Fire(vo : Vector2) -> void:
	if IsCoolingDown: return
	if data.ActionType:
		if TriggerPulled: return
		TriggerPulled = true
	var p : Projectile = BulletPrototype.instance()
	p.global_position = global_position
	p.VelocityOffset = vo
	p.global_rotation = global_rotation
	p.Team = Team
	p.Construct()
	Game.AddWorldNode(p)
	if data.NFEPrototype:
		var ps : NuzzleFireEffect = data.NFEPrototype.instance()
		ps.global_position = global_position + Vector2(0, -24).rotated(global_rotation)
		ps.global_rotation = global_rotation
		ps.z_index -= 2
		Game.AddWorldNode(ps)
#	ps.restart()
	
	IsCoolingDown = true
	CooldwonTimer.start()

func StopedFiring() -> void:
	if data.ActionType == data.ACTIONTYPE_SEMIAUTO:
		TriggerPulled = false

func CooldownDone() -> void:
	IsCoolingDown = false
