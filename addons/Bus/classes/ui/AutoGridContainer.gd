class_name AutoGridContainer extends Container

export(int, 0, 1024) var HSep : int = 0
export(int, 0, 1024) var VSep : int = 0

func _notification(what: int) -> void:
	if what == NOTIFICATION_SORT_CHILDREN:
		var columns : int = 1
		var hight : float
		var nodes : int
		for x in get_children():
			if !x is Control: continue
			hight += (x as Control).rect_min_size.y
			nodes += 1
		hight += (nodes - 1) * HSep
		columns = hight / rect_size.y
		var w : float = rect_size.x / columns
		var c_index : int = 0
		var first : bool = true
		for x in get_children():
			if !x is Control: continue
			if !first:
				fit_child_in_rect(x, Rect2())
			
			
			first = false

