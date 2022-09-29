class_name REGEX extends RegEx

var errors : int

func _init(pat : String = "") -> void:
	if pat: errors = compile(pat)
