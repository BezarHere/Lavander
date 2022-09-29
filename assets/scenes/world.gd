class_name BaseWorld extends Node2D

var rng := RNG.new()
var Current : int

onready var WorldObjsBases : Array = [
	$world_objs1,
	$world_objs2,
	$world_objs3,
	$world_objs4,
]

func _init() -> void:
	Game.MainWorld = self

func _ready() -> void:
	var p : Player = DataManger.EntitesPrototypes["glimer"][0].instance()
	add_child(p)
	p.Construct()
	
	
	
	$border/pol.polygon = Circle(2048, 512)
	
	SpawnCurrentWave()

func Circle(r : int, qual : int) -> PoolVector2Array:
	var p := PoolVector2Array()
	var dom : float = qual / TAU
	for x in qual: p.append(Vector2(r, 0).rotated(x / dom))
	return p

func AddWorldObj(o : Node) -> void:
	Current += 1
	WorldObjsBases[Current % 4].add_child(o)

func SpawnCurrentWave() -> void:
	Game.ActiveWave = Game.CurrentLevelData.Waves[Game.CurrentWave]
	
	var spawned_groups_count : int
	for x in Game.ActiveWave.Enemies.size():
		var g : EnemyGroup = Game.ActiveWave.Enemies[x]
		if rng.randf() > g.chance: continue
		spawned_groups_count += 1
		for i in rng.RoundRandom(g.amount.Random()):
			get_tree().create_timer(g.spawn_time.Random()).connect("timeout", self, "SpawnEnemy", [g.id, g.effects])

func SpawnEnemy(id : String, effects : Array) -> void:
	var e : BOT = DataManger.EntitesPrototypes[id][1].instance()
	e.global_position = rng.rand_circle(2048)
	e.Team += 1
	AddWorldObj(e)
	e.Construct()
