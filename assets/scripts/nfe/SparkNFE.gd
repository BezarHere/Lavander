class_name SparkNFE extends NuzzleFireEffect

var Poly : Polygon2D

static func TypeID() -> String: return "spark"

func Build(data : Dictionary) -> void:
	Ratio2 = 1.0 / 5.0
	.Build(data)

func BuildNodes() -> void:
	Poly = Polygon2D.new()
	Poly.polygon = [
		Vector2(), Vector2(Size * Ratio, -Size * Ratio2),
		Vector2(0, -Size), Vector2(-Size * Ratio, -Size * Ratio2)
	]
	Poly.color = color
	add_child(Poly)
	RegisterNode(Poly, "poly")

func LoadNodes() -> void:
	get_tree().create_timer(time + 0.5).connect("timeout", self, "kill")
	Poly = ExtractNode("poly")
	Poly.create_tween().tween_property(Poly, "scale:x", 0.0, time).set_trans(Tween.TRANS_CUBIC)


