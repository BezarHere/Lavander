tool
class_name Filler extends Container

func _notification(what: int) -> void:
	if what == NOTIFICATION_SORT_CHILDREN:
		var child_count : int = get_child_count()
		if child_count == 0: return
		var rot_step : float = TAU / child_count
		var size : Vector2 = rect_size / child_count
		var rot : float
		for x in get_children():
			fit_child_in_rect(x, Rect2(Vector2.UP.rotated(rot) * min(rect_size.x, rect_size.y) / 2.0 - (size/2.0) + (rect_size / 2.0),size))
			rot += rot_step
