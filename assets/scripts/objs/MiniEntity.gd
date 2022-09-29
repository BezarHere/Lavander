class_name MiniEntity extends KinematicBody2D

var rng := RNG.new()

export var net_id : int
export(float, EXP, 1.0, 10000.0) var speed : float = 100.0
export(float, 0.01, 10.0) var accel_time : float = 1.0

var velocity : Vector2

export var color : Color = Color.white

func _physics_process(delta: float) -> void:
	if !Net.Online || Net.MasterId == net_id:
		Control(delta)
	velocity = move_and_slide(velocity) * 0.94

func Control(delta : float) -> void:
	if Input.is_key_pressed(KEY_W): velocity.y -= speed / accel_time * delta
	if Input.is_key_pressed(KEY_S): velocity.y += speed / accel_time * delta
	if Input.is_key_pressed(KEY_A): velocity.x -= speed / accel_time * delta
	if Input.is_key_pressed(KEY_D): velocity.x += speed / accel_time * delta

func ChangeColor(to : Color, duration : float = 0.5) -> void:
	create_tween().tween_property(
		self, "color", to, duration
	).set_trans(Tween.TRANS_CUBIC)
