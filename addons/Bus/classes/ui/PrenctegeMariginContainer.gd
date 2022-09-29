tool
class_name PrecntegeContainer extends Container

export var ForAll : bool = false setget Set_ForAll

export(float, 0, 1.0) var LeftPrencent : float = 0.1 setget Set_Left
export(float, 0, 1.0) var RightPrencent : float = 0.1 setget Set_Right
export(float, 0, 1.0) var TopPrencent : float = 0.1 setget Set_Top
export(float, 0, 1.0) var BottomPrencent : float = 0.1 setget Set_Bottom

func Set_ForAll(value : bool) -> void:
	ForAll = value
	queue_sort()

func Set_Left(value : float) -> void:
	LeftPrencent = clamp(value, 0, 1)
	queue_sort()

func Set_Right(value : float) -> void:
	RightPrencent = clamp(value, 0, 1)
	queue_sort()

func Set_Top(value : float) -> void:
	TopPrencent = clamp(value, 0, 1)
	queue_sort()

func Set_Bottom(value : float) -> void:
	BottomPrencent = clamp(value, 0, 1)
	queue_sort()


func GetChild() -> Control: return get_child(0) as Control

func _notification(what: int) -> void:
	if what == NOTIFICATION_SORT_CHILDREN:
		update_configuration_warning()
		if ForAll:
			for x in get_children():
				var c : Control = x
				if !c: continue
				fit_child_in_rect(
					c,
					Rect2(
						rect_size.x * LeftPrencent,
						rect_size.y * TopPrencent,
						rect_size.x - (rect_size.x * RightPrencent) - (rect_size.x * LeftPrencent),
						rect_size.y - (rect_size.y * BottomPrencent) - (rect_size.y * TopPrencent)
					)
				)
		else:
			if get_child_count() != 1: return
			var c := GetChild()
			if c:
				fit_child_in_rect(
					c,
					Rect2(
						rect_size.x * LeftPrencent,
						rect_size.y * TopPrencent,
						rect_size.x - (rect_size.x * RightPrencent) - (rect_size.x * LeftPrencent),
						rect_size.y - (rect_size.y * BottomPrencent) - (rect_size.y * TopPrencent)
					)
				)

func _get_configuration_warning() -> String:
	if !ForAll && get_child_count() > 1:
		return "Can sort only the first child, will not act on any other child."
	return ""


