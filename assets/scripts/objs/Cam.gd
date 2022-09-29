class_name Cam extends Camera2D

var rng := RNG.new()
var IsShaking : bool

var CurrentTween : SceneTreeTween

func Shake(duration : float, power : float = 24.0, freq : float = 20) -> void:
	CurrentTween = create_tween()
	if round(duration * freq) <= 0:
		Log.Error("Invalid shake with a zero or negitve duration and freq producte")
		return
	var shake_rect : Rect2 = Rect2(
		-power / 2.0, -power / 2.0, power, power
	)
	for x in round(duration * freq):
		CurrentTween.tween_property(self, "offset", rng.rand4(shake_rect), 1.0 / freq)
	CurrentTween.tween_property(self, "offset", Vector2.ZERO, 2.0 / freq)
	IsShaking = true
	CurrentTween.tween_callback(self, "StopShake")

func StopShake() -> void:
	CurrentTween.stop()
	CurrentTween = null
	offset = Vector2.ZERO
	IsShaking = false

func ZoomChanged() -> void:
	if current: get_tree().call_group_flags(2, "cam-zoom", "CamZoomChanged", zoom.x)
