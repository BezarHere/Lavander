class_name MiniWorld extends Node2D
const BORDER_SIZE = 256
const SMOOTH_LINES = true
const SMOOTHING_INTERVAL = 16 # Lower is better but more mem and cpu consuming 


var LevelPins : Dictionary

var ViewBase : Node2D
var ConnectionsBase : Node2D
var TweenBase : Tween

var BlockEntry : bool

var CachedNodes : Array

func _init() -> void:
	LevelPins = DataManger.MiniworldData.LevelsPins
	Game.BaseMiniWorld = self

func _ready() -> void:
	
	ViewBase = DataManger.MiniworldData.ViewBase
	ConnectionsBase = DataManger.MiniworldData.ConnectionsBase
	TweenBase = DataManger.MiniworldData.TweenBase
	
	add_child(ViewBase); ViewBase.z_index = -2
	add_child(ConnectionsBase); ConnectionsBase.z_index = -4
	add_child(TweenBase)
	
	CachedNodes.append(DataManger.MiniworldData.SelectionList)
	$ui/base/pc_screen/body/bg/body/sel/body/scroll/cliper.add_child(DataManger.MiniworldData.SelectionList)
	DataManger.MiniworldData.SelectionList.anchor_right = 1
	print(DataManger.MiniworldData.SelectionList.rect_size)
#	DataManger.MiniworldData.SelectionList.anchor_bottom = 1
	

static func BuildWorld() -> void:
	var base : Node2D = Node2D.new()
	var t : = Tween.new()
	var connections := Node2D.new()
	
	var LevelPins : Dictionary
	
	for x in DataManger.Levels:
		var l : LevelPinPoint = DataManger.Levels[x].instance()
		base.add_child(l)
		l.AniTween = t
		l.Construct()
		l.position *= 32
		LevelPins[x] = l
	
	for x in LevelPins:
		var p : LevelPinPoint = LevelPins[x]
		for i in p.data.ConnectedTo.size():
			if !p.data.ConnectedTo[i] in LevelPins:
				Log.Error("Invalid field \"connected_to.%s\", there is no level with the id \"%s\"; error in LevelData(%s) at path \"%s\"" % [i, p.data.ConnectedTo[i], p.id, p.data.path])
				continue
			var p2 : LevelPinPoint = LevelPins[p.data.ConnectedTo[i]]
			var lp := Line2D.new()
			lp.width = 6
			lp.default_color = Color(0.2,0.2,0.2,0.5)
			lp.texture = preload("res://graphics/arrow.png")
			lp.texture_mode = Line2D.LINE_TEXTURE_TILE
			if SMOOTH_LINES:
				var cr := Curve2D.new()
				var dis : float = p.position.distance_to(p2.position)/2.0
				cr.add_point(p.position, Vector2.ZERO, p.position.direction_to(p2.position).round()*dis)
				cr.add_point(p2.position, p2.position.direction_to(p.position).round()*dis, Vector2.ZERO)
				cr.bake_interval = SMOOTHING_INTERVAL
				
				lp.points = cr.get_baked_points()
#				DataManger.SaveRes("res://cr.tres", cr)
			else: lp.points = [p.position, p2.position]
			connections.add_child(lp)
	
	SU.ApplyOwner(base, base)
	
	
	var selection_slider : GridContainer = GridContainer.new()
	selection_slider.columns = 3
	selection_slider.rect_min_size.x = 390
	selection_slider.add_constant_override("hseparation", 2)
	
	for i in 100:
		for x in DataManger.Entites:
			var e : EntityData = DataManger.Entites[x]
			if e.hidden: continue

			var b : ChercterSelectionCard = preload("res://assets/ui/modules/ChercterSelectionCard.tscn").instance()
			b.Build(e)
	#		UiLib.CenterOn(p, b.rect_min_size / 2)
			selection_slider.add_child(b)
			b.connect("pressed", Game, "Redirect_CSCPressed", [b])
	
	
	
	DataManger.MiniworldData.ViewBase = base
	DataManger.MiniworldData.TweenBase = t
	DataManger.MiniworldData.ConnectionsBase = connections
	DataManger.MiniworldData.LevelsPins = LevelPins
	DataManger.MiniworldData.SelectionList = selection_slider

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("enter"):
		for x in LevelPins:
			if LevelPins[x].DetectedMinies:
				GoToLevel(LevelPins[x].data)

func GoToLevel(level : LevelData) -> void:
#	if IsEntryBlocked(): return
	Game.CurrentLevelData = level
	get_tree().change_scene("res://assets/scenes/world.tscn")


func GoBackToMainmenu() -> void:
	get_tree().change_scene("res://assets/scenes/mainmenu.tscn")

func _exit_tree() -> void:
	remove_child(ViewBase)
	remove_child(ConnectionsBase)
	remove_child(TweenBase)
	for x in CachedNodes: remove_child(x)


func RequestChangePlayer() -> void:
	$ui/base/player_custom.show()

func IsEntryBlocked() -> bool:
	return true
	return $ui/base/pc_screen.visible




func OnCSSScrolling() -> void:
	if Settings.FancyUI:
		$ui_tw.interpolate_property(
			DataManger.MiniworldData.SelectionList, "rect_position:y", DataManger.MiniworldData.SelectionList.rect_position.y,
			-(DataManger.MiniworldData.SelectionList.rect_size.y - $ui/base/pc_screen/body/bg/body/sel/body/scroll/cliper.rect_size.y) * ($ui/base/pc_screen/body/bg/body/sel/body/scroll/scroll.value / $ui/base/pc_screen/body/bg/body/sel/body/scroll/scroll.max_value),
			0.2, Tween.TRANS_CUBIC, Tween.EASE_OUT
		)
		$ui_tw.start()
	else:
		DataManger.MiniworldData.SelectionList.rect_position.y = -(DataManger.MiniworldData.SelectionList.rect_size.y - $ui/base/pc_screen/body/bg/body/sel/body/scroll/cliper.rect_size.y) * ($ui/base/pc_screen/body/bg/body/sel/body/scroll/scroll.value / $ui/base/pc_screen/body/bg/body/sel/body/scroll/scroll.max_value)

func ChercterSeleceted(card : ChercterSelectionCard) -> void:
	Game.PlayerChercter = card.data.id
	UpdateChercterUI()

func UpdateChercterUI() -> void:
	var e : EntityData = DataManger.Entites[Game.PlayerChercter]
	$ui/base/pc_screen/body/bg/body/doc/icon.texture = e.Icon()
	if $ui/base/pc_screen/body/bg/body/doc/icon.texture:
		$ui/base/pc_screen/body/bg/body/doc/icon.rect_min_size.x = min(192, $ui/base/pc_screen/body/bg/body/doc/icon.texture.get_width())
	$ui/base/pc_screen/body/bg/body/doc/info/name.text = e.name
	$ui/base/pc_screen/body/bg/body/doc/info/desc.text = e.desc
