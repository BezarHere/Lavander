class_name BGStars extends Control



func Resized() -> void:
	$view.size = rect_size / 2
	var max_s : float = max(rect_size.x, rect_size.y)
	$view/base/bp.position = rect_size / 2.0
	($view/base/bp.process_material as ParticlesMaterial).emission_box_extents.x = max_s
	($view/base/bp.process_material as ParticlesMaterial).emission_box_extents.y = max_s
	($view/base/bp.process_material as ParticlesMaterial).orbit_velocity = 0.004
	$view/base/rg.position = rect_size / 2.0
	($view/base/rg.process_material as ParticlesMaterial).emission_box_extents.x = max_s
	($view/base/rg.process_material as ParticlesMaterial).emission_box_extents.y = max_s
	
	$view/base/bp.amount = rect_size.length() * sqrt(2) * 2
	$view/base/rg.amount = (rect_size.length()) * sqrt(2)
	$view/base/bp.restart()
	$view/base/rg.restart()

func play(s : String) -> void:
	$ap.play(s)
