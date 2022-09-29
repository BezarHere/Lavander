extends AudioStreamPlayer
class_name SoundStreamPlayer

var delay : float = -1

func _init(d : float = -1) -> void:
	delay = d

func _ready() -> void:
	if delay < 0: return
	var g : Timer = Timer.new()
	g.autostart = false
	g.one_shot = true
	add_child(g)
	g.owner = self
	g.start(delay)
	g.connect("timeout", self, "Timeout")

func Timeout() -> void: queue_free()
