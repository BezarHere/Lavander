tool
class_name StackContainer extends Container

export(int, 0, 100000) var ColomHight : int = 32

func _ready() -> void: connect("sort_children", self, "SortChildren")

func _notification(what: int) -> void:
	if what == NOTIFICATION_SORT_CHILDREN: SortChildren()

func SortChildren() -> void:
	var width : float
	var coloms : int
	var largest_child_size_v : float
	for x in get_children():
		if !x is Control: continue
		if !x.visible || !x.is_visible_in_tree(): continue
		largest_child_size_v = max(largest_child_size_v, x.rect_min_size.y)
		x.rect_position.x = width
		width += x.rect_min_size.x
		if width > rect_size.x:
			width = x.rect_min_size.x
			coloms += 1
		x.rect_position.y = coloms * ColomHight
	rect_min_size.y = (coloms * ColomHight) + largest_child_size_v
