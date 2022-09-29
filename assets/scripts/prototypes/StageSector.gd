class_name StageSector extends Node2D

export var id : String
var data : StageData

var BaseSprite : Sprite
var GalaxyVisual : Node2D

export var Nodes : Dictionary

export var HasLoaded : bool



func Construct() -> void:
	data = DataManger.Entites[id]
	if HasLoaded:
		LoadData()
	else:
		BuildData()

func BuildData() -> void:
	BaseSprite = Sprite.new()
	GalaxyVisual = Node2D.new()
	
	
	var BaseSprite_texture : = GradientTexture2D.new()
	BaseSprite_texture.gradient = Gradient.new()
	BaseSprite_texture.gradient.colors[0] = Color(1,1,1,0)
	BaseSprite_texture.fill = GradientTexture2D.FILL_RADIAL
	BaseSprite_texture.fill_from = Vector2(0.5,0.5)
	BaseSprite_texture.fill_to = Vector2(1.0,0.5)
	BaseSprite_texture.use_hdr = true
	BaseSprite_texture.width = data.Size
	BaseSprite_texture.height = data.Size
	BaseSprite.texture = BaseSprite_texture
	add_child(BaseSprite)
	
	RegisterNode(BaseSprite, "base_spr")

func NewSpiralGalaxy() -> Array:
	var nodes : Array
	
	var top_parti : = CPUParticles2D.new()
	top_parti.amount = data.Size
	top_parti.orbit_velocity = 10
	nodes.append(top_parti)
	
	return nodes

func BuildNodes() -> void:
	pass

func LoadData() -> void:
	pass

func LoadNodes() -> void:
	pass

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
