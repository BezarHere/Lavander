class_name Intro extends Control

var arr := [] setget set_arr
var rng := RNG.new()

func set_arr(v : Array) -> void:
	arr = v

func _ready() -> void:
	DataManger.connect("done", self, "DoneLoading")
	DataManger.connect("progress", self, "Progress")
	get_tree().create_timer(0.2).connect("timeout" ,self, "StartLoading")

func StartLoading() -> void:
	DataManger.StartLoading()

func DoneLoading() -> void:
	Done()

func Progress(s : String, v : float) -> void:
	$bg/body/progress.value += v
	$bg/body/info.text = s


func BBM() -> void:
	return
	$bg/body/title.bbcode_text = ColorfulTitle()
	pass # Replace with function body.

func ColorfulTitle() -> String:
	create_tween().tween_property(
		Game.GlobalEnvironment, "glow_bloom", rng.randf() * 1.6, 0.3
	)
	var b := "[center]"
	var base : float = rng.randf()
	var i : int
	for x in "Lavander":
		var col := Color().from_hsv(rng.randf_range(base - 0.2, base + 0.2), rng.randf_range(0.5,1.0), 1.0, 1.0)
		create_tween().tween_property(
			$hbc.get_child(7 - i), "color", col, 0.3
		)
#		$hbc.get_child(7 - i).color = col
		i += 1
		b += "[color=#%s]%s[/color]" % [col.to_html(false), x]
	return b

func Done() -> void:
	create_tween().tween_property(
		self, "rect_position:x", -rect_size.x * 1.41, 1.0
	).set_trans(Tween.TRANS_CUBIC)
	Game.BGStars.play("intro_done")
	get_tree().create_timer(1.5).connect("timeout",self,"GoToMainmenu")

func GoToMainmenu() -> void:
	get_tree().change_scene("res://assets/scenes/mainmenu.tscn")


