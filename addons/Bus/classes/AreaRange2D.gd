class_name AreaRange2D extends Area2D
signal DetectsBody(body, entring)

export(float, 0.5, 999999.0) var __size : float # not useful after _ready() was called

var _C := CollisionShape2D.new()


var __Loaded := false

func _ready() -> void:
	Intinalize()

func Intinalize() -> void:
	var s := CircleShape2D.new()
	s.radius = __size
	_C.shape = s
	add_child(_C)

	connect("body_entered", self, "_CCollisionChecks", [true])
	connect("body_exited", self, "_CCollisionChecks", [false])

	collision_layer = 0x0000
	__Loaded = true

func Resize(to : float) -> void:
	__size = to
	if !__Loaded:
		return
	_C.shape.radius = to

func TranformShape(r : Rect2) -> void:
	_C.position = r.position
	_C.scale = r.size

func _CCollisionChecks(b : Node2D, entring : bool) -> void:

	emit_signal("DetectsBody", b, entring)
