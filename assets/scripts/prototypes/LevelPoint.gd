class_name LevelPinPoint extends Node2D

export var id : String
var data : LevelData

var BaseSprite : MultiSprite
var DetectionArea : Area2D
var AniTween : Tween # Set by the MiniWorld
var Auro : CPUParticles2D

var DetectedMinies : Array

export var Nodes : Dictionary
export var HasLoaded : bool

static func GraphicsSuffix(type : int) -> String:
	if type == LevelData.TYPE_LEVEL: return ""
	elif type == LevelData.TYPE_BONUS_LVL: return ".bonus"
	else: return ".boss"

func Construct() -> void:
	if HasLoaded:
		data = DataManger.LevelsData[id]
		LoadData()
	else:
		MakeData()
		HasLoaded = true

func MakeData() -> void:
	add_to_group("lvl-p", true)
	position = data.Position
	MakeTree()

func MakeTree() -> void:
	BaseSprite = MultiSprite.new()
	DetectionArea = Area2D.new()
	Auro = preload("res://assets/objs/PinLevelAuro.tscn").instance()
	
	BaseSprite.textures = [
		data.Graphics.get("locked"),
		data.Graphics.get("unlocked"),
		data.Graphics.get("completed"),
		data.Graphics.get("overdone"), # Beaten to the extream! (like beaten on all Diffs)
	]
	
	
	
	var det_area_col := CollisionShape2D.new()
	det_area_col.shape = CircleShape2D.new()
	det_area_col.shape.radius = 32.0
	DetectionArea.add_child(det_area_col)
	
	Auro.emitting = false
	add_child(Auro)
	
	add_child(BaseSprite)
	add_child(DetectionArea)
	RegisterNode(BaseSprite, "base")
	RegisterNodeTree(DetectionArea, "det_area")
	RegisterNodeTree(Auro, "auro")

func LoadData() -> void:
	LoadTree()

func LoadTree() -> void:
	BaseSprite = ExtractNode("base")
	DetectionArea = ExtractNode("det_area")
	Auro = ExtractNode("auro")
	
	if "starter" in data.Tags: BaseSprite.index = 1
	print(data.Tags)
	
	DetectionArea.connect("body_entered", self, "AreaDetection", [true])
	DetectionArea.connect("body_exited", self, "AreaDetection", [false])

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

func AreaDetection(body : MiniEntity, det : bool) -> void:
	if det:
		if body is MiniEntity: DetectedMinies.append(body)
	else:
		DetectedMinies.erase(body)
	if DetectedMinies:
		AniTween.interpolate_property(
			self, "modulate", self.modulate, Color.white * 1.5, 0.5
		)
		Auro.emitting = true
		AniTween.start()
	else:
		AniTween.interpolate_property(
			self, "modulate", self.modulate, Color.white, 0.5
		)
		Auro.emitting = false
		AniTween.start()
