class_name Math extends Object
const SQRT2M1 = 0.414213562373095048801688724209

static func Dot_M4x4(m0 : Matrix8x8, m1 : Matrix8x8) -> float: return m0.R0.dot(m1.R0) + m0.R1.dot(m1.R1) + m0.R2.dot(m1.R2) + m0.R3.dot(m1.R3)

static func PutOnRect(ang : float, rect : Rect2) -> Vector2:
	var r : float = 1 + (0.414213562373095048801688724209 * sin(ang * 2))
	if wrapf(ang, 0, PI):
		return rect.size * r
	else:
		return rect.size * r

static func BezierCurve_Quadratic(p0 : Vector2, p1 : Vector2, p2 : Vector2, points : int = 16) -> PoolVector2Array:
	var p : PoolVector2Array
	for x in points:
		var ratio : float = x / float(points)
		p.append(p0.linear_interpolate(p1, ratio).linear_interpolate(p1.linear_interpolate(p2, ratio), ratio))
	p.append(p2)
	return p

static func BezierCurve3D_Quadratic(p0 : Vector3, p1 : Vector3, p2 : Vector3, points : int = 16) -> PoolVector3Array:
	var p : PoolVector3Array
	for x in points:
		var ratio : float = x / float(points)
		p.append(p0.linear_interpolate(p1, ratio).linear_interpolate(p1.linear_interpolate(p2, ratio), ratio))
	p.append(p2)
	return p

static func BezierCurve_Cubic(p0 : Vector2, p1 : Vector2, p2 : Vector2, p3 : Vector2, points : int = 16) -> PoolVector2Array:
	var p : PoolVector2Array
	for x in points:
		var ratio : float = x / float(points)
		p.append(
			p0.linear_interpolate(p1, ratio).linear_interpolate(p1.linear_interpolate(p2, ratio), ratio).linear_interpolate(
				p1.linear_interpolate(p2, ratio).linear_interpolate(p2.linear_interpolate(p3, ratio), ratio), ratio
			)
		)
	p.append(p3)
	return p


static func ToBezierCurve_Quadratic(ps : PoolVector2Array, points_per_segment : int = 16) -> PoolVector2Array:
	if ps.size() <= 2: return ps
	var p : PoolVector2Array = [ps[0]]
	for i in ps.size() - 2:
		for x in points_per_segment:
			var ratio : float = x / float(points_per_segment)
			p.append(p[-1].linear_interpolate(ps[i + 1], ratio).linear_interpolate(ps[i + 1].linear_interpolate(ps[i + 2], ratio), ratio))
	p.append(ps[-1])
	return p

static func ToBezierCurve3D_Quadratic(ps : PoolVector3Array, points_per_segment : int = 16) -> PoolVector3Array:
	if ps.size() <= 2: return ps
	var p : PoolVector3Array = [ps[0]]
	for i in ps.size() - 2:
		for x in points_per_segment:
			var ratio : float = x / float(points_per_segment)
			p.append(p[-1].linear_interpolate(ps[i + 1], ratio).linear_interpolate(ps[i + 1].linear_interpolate(ps[i + 2], ratio), ratio))
	p.append(ps[-1])
	return p

