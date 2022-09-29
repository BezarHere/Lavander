class_name Point extends Node2D

var Size : float
var color : Color = Color.white

func DistanceTo(p : Point) -> float:
	return global_position.distance_to(p.global_position)

func Draw() -> void: update()

func _draw() -> void:
	draw_circle(Vector2.ZERO, Size, color)
