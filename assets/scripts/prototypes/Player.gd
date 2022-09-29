class_name Player extends Entity

var NetID : int
var IsDummy : bool

var Cam_p : Cam

func _to_string() -> String: return "Player(%s, %s, %s)" % [id, IsDummy, NetID]

func _ready() -> void:
	Game.connect("broudcast", self, "ReciveEvent")
	if Net.Online:
		IsDummy = NetID != Net.MasterId
	name = "Player_" + str(NetID)
	if !IsDummy:
		Game.SetupMainPlayer(self)
#	ChangedPuppetState()

func _physics_process(delta: float) -> void:
	if IsDummy:
		
		
		return
	Movemnet(delta)

func Movemnet(d : float) -> void:
	if Input.is_key_pressed(KEY_W) && Velocity.y > -MaxSpeed:
		Velocity.y -= Speed * d
	elif Input.is_key_pressed(KEY_S) && Velocity.y < MaxSpeed:
		Velocity.y += Speed * d
	if Input.is_key_pressed(KEY_A) && Velocity.x > -MaxSpeed:
		Velocity.x -= Speed * d
	elif Input.is_key_pressed(KEY_D) && Velocity.x < MaxSpeed:
		Velocity.x += Speed * d
	Velocity *= 0.92
	Velocity = move_and_slide(Velocity)
	global_rotation = SmoothRot(global_rotation, global_position.angle_to_point(get_global_mouse_position()) - 1.5708, 0.1)
	
	if Input.is_action_pressed("lmb"): weapon.Fire(Velocity)
	elif Input.is_action_just_released("lmb"): weapon.StopedFiring()
	

func MakeTree() -> void:
	.MakeTree()
	Cam_p = Cam.new()
	Cam_p.current = true
	Cam_p.smoothing_enabled = true
	Cam_p.zoom = Vector2(2,2)
	add_child(Cam_p)
	RegisterNode(Cam_p, "Cam_p")

func LoadTree() -> void:
	.LoadTree()
	Cam_p = get_node_or_null(Nodes.Cam_p)
	Cam_p.call_deferred("ZoomChanged")
	call_deferred("ChangedPuppetState")

func ReciveEvent(event : Dictionary) -> void:
	if event.type == "entity_death":
		Cam_p.Shake(0.4)

func ChangedPuppetState() -> void:
	if Cam_p: Cam_p.current = !IsDummy
	if Hud: Hud.visible = IsDummy
