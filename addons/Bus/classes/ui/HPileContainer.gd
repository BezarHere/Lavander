tool
class_name HPileContainer extends Container

export(int, -999, 999) var HSepration : int = 3 setget Set_HSepration
export(int, -999999, 999999) var Hight : int = 32 setget Set_Hight
var rows : int

func Set_HSepration(value : int) -> void:
	HSepration = value
	queue_sort()

func Set_Hight(value : int) -> void:
	Hight = value
	queue_sort()

func _notification(what: int) -> void:
	if what == NOTIFICATION_SORT_CHILDREN:
		update_configuration_warning()
		var pile_size : int
		rows = 0
		for x in get_child_count():
			var c := get_child(x)
			if c is Control:
				if c is ColorRect: c.color = c.color.from_hsv((x % 256) / 256.0, 1.0, 1.0, 1.0)
				if pile_size + c.rect_size.x + (HSepration if x else 0) >= rect_size.x:
					pile_size = 0
					rows += 1
				fit_child_in_rect(
					c,
					Rect2(Vector2(pile_size, rows * Hight), c.rect_min_size)
				)
			pile_size += HSepration
			pile_size += c.rect_size.x
