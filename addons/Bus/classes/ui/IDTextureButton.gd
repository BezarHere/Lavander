extends Button
class_name IDTextureButton

export var id : int
var _t_ : String
var Sound := true

func _ready():

	connect("button_down", self, "PlaySound", [0])
	connect("mouse_entered", self, "PlaySound", [1])

func PlaySound(i : int) -> void:
	if !Sound:
		return
#	var v : float = -14.0
#	if i == 1:
#		v = -24.0
	if i == 1 and disabled:
		return
#	SoundEngine.play(i, v, -3, 1.0)

