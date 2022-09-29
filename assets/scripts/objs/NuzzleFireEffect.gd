class_name NuzzleFireEffect extends Node2D

export var id : String # Of the parent
export var path : String # Of the parent

export var time : float = 1.0
export var color : Color
export var gradient : Gradient

export var Size : float = 16

export var Ratio : float = 0.5
export var Ratio2 : float = 0.33333
export var Ratio3 : float = 0.25

export var Graphics : Dictionary

export var texture : Texture

export var Nodes : Dictionary

export var IsBuilt : bool

static func TypeID() -> String: return "base"


func _ready() -> void:
	if IsBuilt: Load()

func Build(data : Dictionary) -> void:
	var trace : String = "in NFE(%s) at path \"%s\"" % [id, path]
	
	time = ParseUtility.CheckForNumperPositiveNonzero("time", data, trace, {default = time, trace_id = "time"})
	if "color" in data: color = ParseUtility.CheckForColor("color", data, trace, {default = time, trace_id = "color"})
	if "gradient" in data: gradient = ParseUtility.CheckForGradient("gradient", data, trace, {trace_id = "gradient"})
	if "size" in data: Size = ParseUtility.CheckForNumperPositiveNonzero("gradient", data, trace, {default = Size, trace_id = "gradient"})
	if "scale" in data: scale = ParseUtility.CheckForVector2("scale", data, trace, {default = scale, trace_id = "scale"})
	if "rot" in data: rotation = ParseUtility.CheckForNumperPositiveNonzero("rot", data, trace, {default = rotation, trace_id = "rot"})
	if "ratio" in data: Ratio = clamp(ParseUtility.CheckForNumperPositiveNonzero("ratio", data, trace, {default = Ratio, trace_id = "ratio"}),0.0001, 1.0 / 0.0001)
	if "ratio2" in data: Ratio2 = clamp(ParseUtility.CheckForNumperPositiveNonzero("ratio2", data, trace, {default = Ratio, trace_id = "ratio2"}),0.0001, 1.0 / 0.0001)
	if "ratio3" in data: Ratio3 = clamp(ParseUtility.CheckForNumperPositiveNonzero("ratio3", data, trace, {default = Ratio, trace_id = "ratio3"}),0.0001, 1.0 / 0.0001)
	
	if "texture" in data:
		texture = DataManger.LoadGraphics(ParseUtility.CheckForDictionary("texture", data, trace, {default = {}, trace_id = "texture"}), {id = id, subid = "texture", path = path})
	
	if "graphics" in data:
		var graphics : Dictionary = ParseUtility.CheckForDictionary(
			"graphics",
			data,
			trace,
			{default = {}, trace_id = "graphics"}
		)
		
		for x in graphics:
			Graphics[x] = DataManger.LoadGraphics(
				ParseUtility.CheckForDictionary(x, graphics, trace, {default = {}, trace_id = ParseUtility.AddKey("graphics", x)}),
				{id = id, subid = ParseUtility.AddKey("graphics", x), path = path}
			)
	
	BuildNodes()
	
	IsBuilt = true

func BuildNodes() -> void:
	pass

func Load() -> void:
	LoadNodes()

func LoadNodes() -> void:
	pass

func RegisterNode(node : Node, id : String) -> void:
	node.name = id
	node.owner = self
	Nodes[id] = self.get_path_to(node)

func ExtractNode(id : String) -> Node: return get_node_or_null(Nodes[id])

func kill() -> void: queue_free()
