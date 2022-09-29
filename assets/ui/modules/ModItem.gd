class_name ModItem extends Button
var id : String

var InTree : bool

func _ready() -> void:
	InTree = true

func Build() -> void:
	$hbc/enabled.pressed = DataManger.Mods[id].enabled
	$hbc/name.text = DataManger.Mods[id].name
	$hbc/ver.text = DataManger.Mods[id].version_text
	$hbc/name.modulate = Color.lightgreen if DataManger.Mods[id].loaded else Color.dimgray

func IsEnabled() -> bool:
	assert(InTree)
	return $hbc/enabled.pressed
