extends HSlider
class_name SoundedHSlider

func _ready():
	connect("value_changed", self, "PlaySound")

func PlaySound(n) -> void: pass
#	SoundEngine.play(2, 0.3, -3, 2.0)
