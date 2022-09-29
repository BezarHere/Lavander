class_name UiLib extends ObjectStructure

static func NotifyResized(p : Control,m : String, args : Array = [], f : int = 0) -> void: NotifyResizedOn(p,p,m,args,f)

static func NotifyResizedOn(p0 : Control, p1 : Object,m:String, args : Array = [], f : int = 0) -> void:
	p0.connect("resized", p1, m, args, f)

static func NotifyMouseDetection(p0 : Control, p1 : Object, m : String, args : Array = [], f :int = 0) -> void:
	p0.connect("mouse_entered", p1, m, [true] + args, f)
	p0.connect("mouse_exited", p1, m, [false] + args, f)

static func ApplyRect(c : Control, r : Rect2, global : bool = false) -> void:
	if global:
		c.rect_global_position = r.position
		c.rect_size = r.size
	else:
		c.rect_position = r.position
		c.rect_size = r.size

static func ApplyRectCentered(c : Control, r : Rect2, global : bool = false) -> void:
	if global:
		c.rect_global_position = r.position - (r.size / 2.0)
		c.rect_size = r.size
	else:
		c.rect_position = r.position - (r.size / 2.0)
		c.rect_size = r.size

static func CenterOn(c : Control, r : Vector2 = Vector2.ZERO, global : bool = false) -> void:
	if global:
		c.rect_global_position = r-(c.rect_size / 2.0)
	else:
		c.rect_position = r-(c.rect_size / 2.0)

static func Focus(n:Node) -> void:
	if !n||!n.get_parent(): return
	n.get_parent().move_child(n,n.get_parent().get_child_count())



