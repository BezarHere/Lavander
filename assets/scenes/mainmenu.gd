extends Control
"""
Big 'ol script
don't mess with shit
!! See the comments !!
"""

var InAction : bool
var ModsItems : Dictionary
var _ModsSet : Dictionary

func _ready() -> void:
	rect_position.x = -rect_size.x * 1.41
	SlideIn()
	Init()

func Init() -> void:
	$mods.hide()
	BuildModsList()
	$mods/cont/body/buttons/cancel.connect("pressed", self, "GoBackFromMods")
	$mods/cont/body/buttons/cancel.connect("pressed", self, "Cancel_ModsChanges")
	$mods/cont/body/buttons/apply.connect("pressed", self, "GoBackFromMods")
	$mods/cont/body/buttons/apply.connect("pressed", self, "Apply_ModsChanges")
	$mods/cont/body/buttons/conf.connect("pressed", self, "GoBackFromMods")
	$mods/cont/body/buttons/conf.connect("pressed", self, "Conf_ModsChanges")


func OpenMyTweeter() -> void:
	OS.shell_open("https://tweeter.org/BotatoDev")


func OnPlayPressed() -> void:
	QueueCallAfterSlide("GoToWorld")

func GoToWorld() -> void: get_tree().change_scene("res://assets/scenes/MiniWorld.tscn")

func QueueCallAfterSlide(call : String, reslide : bool = false) -> void:
	SlideOut()
	Game.BGStars.play("slide_left")
	get_tree().create_timer(1.0,false).connect("timeout", self, call)
	if reslide:get_tree().create_timer(1.0,false).connect("timeout", self, "SlideIn")

func SlideOut() -> void:
	create_tween().tween_property(
		self, "rect_position:x", -rect_size.x * 1.41, 1.0
	).set_trans(Tween.TRANS_CUBIC)

func SlideIn() -> void:
	create_tween().tween_property(
		self, "rect_position:x", 0.0, 1.0
	).set_trans(Tween.TRANS_EXPO)


func OnModsPressed() -> void:
	QueueCallAfterSlide("ShowMods", true)

func ShowMods() -> void:
	CatchModsSettings()
	$mods.visible = true

func HideMods() -> void:
	$mods.hide()

func BuildModsList() -> void:
	for x in DataManger.Mods:
		var p : ModItem = preload("res://assets/ui/modules/ModItem.tscn").instance()
		p.id = x
		$mods/cont/body/body/items/mods/list/body.add_child(p)
		p.Build()
		ModsItems[x] = p

func GoBackFromMods() -> void:
	QueueCallAfterSlide("HideMods", true)

func Cancel_ModsChanges() -> void:
	ReloadModsItems()

func Apply_ModsChanges() -> void:
	Conf_ModsChanges()
	if CheckModsChanges():
		Game.RestartProgram()

func Conf_ModsChanges() -> void:
	ApplyModsItems()

func ReloadModsItems() -> void:
	for x in ModsItems:
		ModsItems[x].Build()

func ApplyModsItems() -> void:
	for x in ModsItems:
		DataManger.Mods[x].enabled = ModsItems[x].IsEnabled()

# Catch Mods settings for comparsion later
func CatchModsSettings() -> void:
	_ModsSet.clear()
	for x in DataManger.Mods:
		_ModsSet[x] = {enabled = DataManger.Mods[x].enabled, piority = DataManger.Mods[x].piority}

# Has mods settings changed from when we catched it
func CheckModsChanges() -> bool:
	for x in DataManger.Mods:
		if _ModsSet[x].enabled != DataManger.Mods[x].enabled || _ModsSet[x].piority != DataManger.Mods[x].piority: return true
	return false


func OpenMyDiscrod() -> void:
	pass # Replace with function body.
