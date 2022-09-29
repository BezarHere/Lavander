class_name NumperLineEdit extends LineEdit
signal invalid_text_entered

# Cant do negtives with EXP
export(float,EXP, 0.001, 10000000) var max_num : float = 100
export(float,EXP, 0, 9999999) var min_num : float = 0

var num : float

func _ready() -> void:
	connect("text_entered", self ,"OnTextEntered")
	OnTextEntered(text)

func OnTextEntered(n : String) -> void:
	if !n.is_valid_float():
		emit_signal("invalid_text_entered", n)
	else:
		num = clamp(float(n), min_num, max_num)
	text = str(num)
	release_focus()
