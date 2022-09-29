class_name ValueCurve extends Curve

var _cached_points : PoolVector2Array
var started_points : bool
export var max_offset : float = 1.0

func value_at(x : float) -> float: return interpolate(x/max_offset)

func setup_point(x : float, y : float) -> void:
	if !started_points: start_points()
	max_offset = max(max_offset, x)
	max_value = max(max_value, y)
	_cached_points.append(Vector2(x,y))
func setup_points(p : PoolVector2Array) -> void:
	for x in p: setup_point(x.x, x.y)

func start_points() -> void:
	_cached_points = []
	clear_points()
	max_offset = 1; max_value = 1
	started_points = true

func apply_points() -> void:
	for x in _cached_points:
		add_point(Vector2(x.x/max_offset,x.y))
	started_points = false
