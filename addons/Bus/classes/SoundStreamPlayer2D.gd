extends AudioStreamPlayer2D
class_name SoundStreamPlayer2D

export var delay : float = 0.2
#var timer : Timer

func _init(d : float = 0.2) -> void:
	delay = d

func _ready() -> void:
#	if delay < 0: return
	get_tree().create_timer(delay + stream.get_length()).connect("timeout", self, "Timeout")

func Timeout() -> void: queue_free()
