class_name Consol extends Panel

var ArgsPat : RegEx = REGEX("[\\w\\d\\.\\,\\?\\\\\\/\\:]+|['\"\"]+|\\s+")

static func REGEX(s : String) -> RegEx:
	var r := RegEx.new()
	r.compile(s); return r

func _ready() -> void:
	for x in Log.history:
		Loged(x)
	Log.connect("log_fired", self,"Loged")

func Loged(l : Dictionary) -> void:
	var p := Label.new()
	p.text = Log.ParseLog(l)
	p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	p.autowrap = true
	p.theme_type_variation = "CodeLabel"
	match l.type:
		"err": p.modulate = Color.tomato
		"wrn": p.modulate = Color.gold
	$body/scroll/list.add_child(p)


func OnDoneLoading() -> void:
	var h : HFlowContainer = HFlowContainer.new()
	h.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	h.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var d : Dictionary = DataManger.Graphics.duplicate(true)
	for x in d:
		var t := TextureRect.new()
		t.texture = d[x]
		t.hint_tooltip = "Path: %s" % [d[x].path]
		t.size_flags_vertical = 0
		t.size_flags_horizontal = 0
		h.add_child(t)
		var p := ReferenceRect.new()
		p.editor_only = false
		p.border_width = 1.5
		p.border_color = Color.white
		p.mouse_filter = Control.MOUSE_FILTER_IGNORE
		t.add_child(p)
		p.anchor_right=1
		p.anchor_bottom=1
	$body/scroll/list.add_child(h)

func GetArgs(s : String) -> Array:
	var result : Array
	var reg : Array = ArgsPat.search_all(s)
	var args : Array; for x in reg: args.append_array(x.strings)
	
	var i_max : int = args.size()
	var i : int
	var current_arg : String
	var in_str : int
	while i < i_max:
		if " " in args[i] || "\t" in args[i] || "\n" in args[i]:
			if in_str:
				current_arg += args[i]
			else:
				result.append(current_arg)
			i += 1
			continue
		
		
	
	
	return result
