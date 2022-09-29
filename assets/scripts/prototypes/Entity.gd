class_name Entity extends KinematicBody2D
signal health_changed(delta)

var rng := RNG.new()
var UID : int
export var id : String
var data : EntityData

export var Nodes : Dictionary
export var SetupData : Dictionary

export var MaxHealth : int
var Health : float = MaxHealth

export var Speed : float = 30
export var MaxSpeed : float = 20
var Velocity : Vector2

var level : int
var xp : float

export var Team : int

export var Weapons : Array

export var Multiplaiers : Dictionary



var BaseSprite : Sprite
var TopSprite : Sprite
var OverlaySprite : Sprite
var UnderlaySprite : Sprite
var BottomSprite : Sprite
var ShadowSprite : Sprite
var LighSprite : Sprite

var FreeBase : Node
var FloaterBase : Node2D

var FloatingWeapons : Node2D
var FixedWeapons : Node2D

var FloaterRemote : RemoteTransform2D

var weapon : BaseWeapon

var Hud : Control


export var HasLoaded : bool

var Accel : float

func _ready() -> void:
	connect("tree_exiting", self, "OnExitingTree")

func Construct() -> void:
	data = DataManger.Entites[id]
	if HasLoaded:
		LoadData()
	else:
		MakeData()

func MakeData() -> void:
	add_to_group("entity", true)
	
	MaxHealth = data.MaxHealth
	Speed = data.Speed
	MaxSpeed = data.MaxSpeed
	MakeTree()

func MakeTree() -> void:
	BaseSprite = Sprite.new()
	TopSprite = Sprite.new()
	BottomSprite = Sprite.new()
	ShadowSprite = Sprite.new()
	LighSprite = Sprite.new()
	OverlaySprite = Sprite.new()
	UnderlaySprite = Sprite.new()
	FreeBase = Node.new()
	FloaterBase = Node2D.new()
	FloaterRemote = RemoteTransform2D.new()
	FloatingWeapons = Node2D.new()
	FixedWeapons = Node2D.new()
	weapon = BaseWeapon.new()
	Hud = ReferenceBirdge.InstanceScene("entity_hud")
	
	BaseSprite.texture = data.Graphics.get("base", DataManger.DEFAULT)
	add_child(BaseSprite)
	TopSprite.texture = data.Graphics.get("top", null)
	BaseSprite.add_child(TopSprite)
	TopSprite.z_index += 2
	BottomSprite.texture = data.Graphics.get("bot", null)
	BaseSprite.add_child(BottomSprite)
	BottomSprite.z_index -= 2
	ShadowSprite.texture = data.Graphics.get("shadow", null)
	BaseSprite.add_child(ShadowSprite)
	ShadowSprite.z_index -= 4
	LighSprite.texture = data.Graphics.get("light", null)
	BaseSprite.add_child(LighSprite)
	LighSprite.z_index += 3
	
	add_child(FreeBase)
	FreeBase.add_child(FloaterBase)
	add_child(FloaterRemote)
	FloaterRemote.update_rotation = false
	FloaterBase.add_child(FloatingWeapons)
	FloaterBase.z_index += 1
	add_child(FixedWeapons)
	
	
	OverlaySprite.texture = data.Graphics.get("overlay", null)
	FloaterBase.add_child(OverlaySprite)
	OverlaySprite.z_index += 3
	UnderlaySprite.texture = data.Graphics.get("underlay", null)
	FloaterBase.add_child(UnderlaySprite)
	UnderlaySprite.z_index -= 3
	
	
	if data.WeaponPrototype: weapon = data.WeaponPrototype.instance()
	weapon.Team = Team
	FixedWeapons.add_child(weapon)
	
	OverlaySprite.add_child(Hud)
	UiLib.CenterOn(Hud, data.HudOffset)
	
	for x in data.HitBoxes.size():
		var pdata : Dictionary = data.HitBoxes[x]
		if pdata.get("is_poly", false):
			var sp : CollisionPolygon2D = CollisionPolygon2D.new()
			sp.polygon = pdata.poly
			sp.position = pdata.offset
			sp.name = "hitbox_%s" % [x]
			add_child(sp)
			RegisterNode(sp, "hitbox_%s" % x)
			continue
		var sp : CollisionShape2D = CollisionShape2D.new()
		sp.shape = pdata.shape
		sp.position = pdata.offset
		sp.name = "hitbox_%s" % [x]
		add_child(sp)
		RegisterNode(sp, "hitbox_%s" % x)
	
#	FloaterRemote.remote_path = FloaterRemote.get_path_to(FloaterBase)
	
	RegisterNode(BaseSprite, "base")
	RegisterNode(TopSprite, "top")
	RegisterNode(BottomSprite, "bot")
	RegisterNode(ShadowSprite, "shadow")
	RegisterNode(LighSprite, "light")
	RegisterNode(OverlaySprite, "overlay")
	RegisterNode(UnderlaySprite, "underlay")
	
	RegisterNode(FreeBase, "free_base")
	RegisterNode(FloaterBase, "floater")
	RegisterNode(FloaterRemote, "floater_remote")
	
	
	RegisterNode(FloatingWeapons, "floating_weapons")
	RegisterNode(FixedWeapons, "fixed_weapons")
	
	RegisterNodeTree(weapon, "weapon")
	
	RegisterNode(Hud, "hud")

func LoadData() -> void:
	UID = rng.randi64()
	Game.AddTeamedEntity(self)
	Health = SetupData.get("health", MaxHealth)
	LoadTree()

func LoadTree() -> void:
	BaseSprite = get_node_or_null(Nodes.base)
	TopSprite = get_node_or_null(Nodes.top)
	BottomSprite = get_node_or_null(Nodes.bot)
	ShadowSprite = get_node_or_null(Nodes.shadow)
	LighSprite = get_node_or_null(Nodes.light)
	OverlaySprite = get_node_or_null(Nodes.overlay)
	UnderlaySprite = get_node_or_null(Nodes.underlay)
	
	FreeBase = get_node_or_null(Nodes.free_base)
	FloaterBase = get_node_or_null(Nodes.floater)
	FloaterRemote = get_node_or_null(Nodes.floater_remote)
#	FloaterRemote.force_update_cache()
	FloaterRemote.remote_path = FloaterRemote.get_path_to(FloaterBase)
	
	FloatingWeapons = get_node_or_null(Nodes.floating_weapons)
	FixedWeapons = get_node_or_null(Nodes.fixed_weapons)
	
	weapon = get_node_or_null(Nodes.weapon)
	weapon.Construct()
	
	Hud = get_node_or_null(Nodes.hud)
	Hud.BindWith(self)
	
	if weapon: weapon.Construct()

func RegisterNodeTree(node : Node, id : String) -> void:
	node.name = id
	var ns : Array = [node]
	while ns:
		var p: Node = ns.pop_back()
		p.owner = self
		ns.append_array(p.get_children())
	Nodes[id] = self.get_path_to(node)

func RegisterNode(node : Node, id : String) -> void:
	node.name = id
	node.owner = self
	Nodes[id] = self.get_path_to(node)

func ExtractNode(id : String) -> Node: return get_node_or_null(Nodes[id])

func SendPhysics() -> void:
	rpc("RecivePhysics", transform, Velocity)

puppet func RecivePhysics(tr : Transform2D, vel : Vector2) -> void:
	transform = tr

func _to_string() -> String: return "Entity(%s)" % [id]

func SmoothRot(from : float, to : float, speed : float) -> float: return clamp(lerp_angle(from, to, 1.0), from - speed, from + speed)

func Hurt(damage : Dictionary) -> void:
	Health -= damage.amount
	emit_signal("health_changed", -damage.amount)
	if Health <= 0:
		Die()

func Die() -> void:
	Game.Broudcast({type = "entity_death", entity = self, team = Team, position = global_position, id = id})
	queue_free()

func OnExitingTree() -> void:
	Game.RemoveTeamedEntity(self)

