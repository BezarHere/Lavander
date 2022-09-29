class_name ChercterSelectionCard extends Panel
signal pressed

var data : EntityData

func _ready() -> void:
	add_to_group("crs_button", true)

func Build(e : EntityData) -> void:
	data = e
	$vbc/title.text = e.name
	$vbc/icon.texture = e.Graphics.get("icon", e.Graphics.get("base", DataManger.DEFAULT_RAW))
	if $vbc/icon.texture:
		$vbc/icon.rect_min_size.x = min(rect_size.x, $vbc/icon.texture.get_width())
	$stats/body/health_icon.texture = DataManger.GetGraphicsSafe("ui.icons.health")
	$stats/body/health_text.text = str(round(e.Power(1)))
	$stats/body/speed_icon.texture = DataManger.GetGraphicsSafe("ui.icons.speed")
	$stats/body/speed_text.text = str(round(e.Power(0)/32))
	$stats/body/pwr_icon.texture = DataManger.GetGraphicsSafe("ui.icons.power")
	$stats/body/pwr_text.text = str(round(e.Power(2)))

func UpdateSelection(id : String) -> void:
	if data.id != id: $button.pressed = false

func OnToggled(to : bool) -> void:
	if to:
		get_tree().call_group("crs_button", "UpdateSelection", data.id)
		emit_signal("pressed")
	else:
		$button.pressed = true
