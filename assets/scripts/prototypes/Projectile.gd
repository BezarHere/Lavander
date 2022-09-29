class_name Projectile extends Area2D

export var id : String

var data : ProjectileData

var CustomData : ObjectTweaks = ObjectTweaks.new()

var BaseSprite : Sprite
var TrailLine : Line2D
var HitboxShape : CollisionShape2D

export var Nodes : Dictionary
export var TData : Dictionary
export var HasLoaded : bool

var LifetimeTimer : SceneTreeTimer

export var Team : int

var VelocityOffset : Vector2

var Damage_Type : int
var Damage_Amount : float

func Construct() -> void:
	if HasLoaded:
		data = Game.ProjectilesBank[id][0]
		CustomData = Game.ProjectilesBank[id][1]
		LoadData()
	else:
		Game.ProjectilesBank[id] = [data, CustomData]
		BuildData()


func LoadData() -> void:
	Damage_Type = data.Damage_Type
	Damage_Amount = data.Damage_Amount
	LoadNodes()

func LoadNodes() -> void:
	
	TrailLine = ExtractNode("t_line")
	HitboxShape = ExtractNode("hitbox")
	BaseSprite = ExtractNode("base_sprite")

func BuildData() -> void:
	
	
	BuildNodes()
	HasLoaded = true

func BuildNodes() -> void:
	TrailLine = Line2D.new()
	BaseSprite = Sprite.new()
	
	
	BaseSprite.texture = data.Graphics.get("base", null)
	if BaseSprite.texture is LoadedTexture:
		BaseSprite.offset = BaseSprite.texture.offset
	add_child(BaseSprite)
	
	
	TrailLine.width = 8
	TrailLine.default_color = Color.cyan
	TrailLine.points = [Vector2.ZERO, Vector2(0, 48)]
	TrailLine.width_curve = Curve.new()
	TrailLine.width_curve.add_point(Vector2(0, 1))
	TrailLine.width_curve.add_point(Vector2(0.6, 0.4))
	TrailLine.width_curve.add_point(Vector2(1, 0))
	TrailLine.gradient = Gradient.new()
	TrailLine.gradient.set_color(0, Color.cyan)
	TrailLine.gradient.set_color(1, Color(0,1,1,0))
	TrailLine.gradient.interpolation_mode = Gradient.GRADIENT_INTERPOLATE_CUBIC
	add_child(TrailLine)
	TrailLine.visible = false # For now
	
	if data.Hitbox:
		HitboxShape = CollisionShape2D.new()
		HitboxShape.shape = data.Hitbox
		HitboxShape.position = data.HitboxOffset
		add_child(HitboxShape)
	
	var reg_polygons : int
	for x in data.Polygons:
		var p : Polygon2D = data.Polygons[x].instance()
		add_child(p)
		RegisterNode(p, "poly_%s" % [reg_polygons])
		reg_polygons += 1
	TData["reg_polygons"] = reg_polygons
	
	RegisterNode(TrailLine, "t_line")
	RegisterNode(HitboxShape, "hitbox")
	RegisterNode(BaseSprite, "base_sprite")

func RegisterNode(node : Node, id : String) -> void:
	node.name = id
	node.owner = self
	Nodes[id] = self.get_path_to(node)

func ExtractNode(id : String) -> Node: return get_node_or_null(Nodes[id])

func _ready() -> void:
	connect("body_entered" , self , "BodyEntered")
	create_tween().tween_property(
		self, "global_position", global_position + Vector2(0, -1000).rotated(global_rotation) + VelocityOffset, 1.5
	).set_trans(data.MovingTransition).set_ease(data.MovingEase)
	LifetimeTimer = get_tree().create_timer(4.5)
	LifetimeTimer.connect("timeout",self,"queue_free")

func BodyEntered(body : Node2D) -> void:
	ReferenceBirdge.CheckProjectileHit(self, body)
