class_name BOT extends Entity

var Target : Node2D
var RetargetTimer : Timer

func _physics_process(delta: float) -> void:
	
	if Target: AI_MoveToTarget(delta)

func AI_MoveToTarget(delta : float) -> void:
	if global_position.distance_squared_to(Target.global_position) > 8192: Velocity = global_position.direction_to(Target.global_position) * MaxSpeed
	look_at(Target.global_position)
	global_rotation += 1.5708
	Velocity = move_and_slide(Velocity)



func MakeTree() -> void:
	.MakeTree()
	RetargetTimer = Timer.new()
	RetargetTimer.wait_time = 0.5
	RetargetTimer.connect("timeout", self, "RetargetTimeTimeout", [], CONNECT_PERSIST)
	add_child(RetargetTimer)
	RegisterNode(RetargetTimer, "retarget_time")

func LoadTree() -> void:
	.LoadTree()
	RetargetTimer = ExtractNode("retarget_time")
	RetargetTimer.start()

func RetargetTimeTimeout() -> void:
	Target = Game.GetClosestEnemy(Team, global_position)
