extends Node
signal esc_warnning
signal broudcast(event)
signal main_player_set
signal main_player_removed
signal main_team_changed
signal inventory_changed(type)

enum ITEMS {
	PHOTONS
	STAR_DUST
	XP
	LEVEL
}

var GlobalEnvironment : Environment = preload("res://env.tres")
var GlobalWorldEnvironment := WorldEnvironment.new()
var BGLayer := CanvasLayer.new()
var BGStars : BGStars
var IsPPEEnabled : bool = true

# <ProjectileID> : [Data, CustomData]
var ProjectilesBank : Dictionary

# <WeaponID> : [Data, CustomData]
var WeaponsBank : Dictionary

var MainTeam : int
var MainPlayer : Player

var TeamedEntites : Array

var ConsolPanel : Consol = preload("res://assets/ui/Consol.tscn").instance()

var BaseMiniWorld : MiniWorld
var MainWorld : BaseWorld

var MiniEntityData : Dictionary

# Inventory

var Photons : float
var StarDust : float
var Xp : float
var Level : int

var CurrentLevelData : LevelData
var CurrentWave : int
var ActiveWave : WaveInfo

var CherctersData : Dictionary
var PlayerChercter : String

var LevelsStats : Dictionary
var Stats : Dictionary

func ResetMiniEntity() -> void:
	MiniEntityData = {
		position = Vector2.ZERO,
		rotation = 0.0,
		
	}

static func SavePath() -> String: return FU.DecumentsFolder().plus_file("My Games").plus_file(DataManger.GAMENAME).plus_file("data.bin")
static func SaveFolder() -> String: return FU.DecumentsFolder().plus_file("My Games").plus_file(DataManger.GAMENAME)

func _init() -> void:
	FU.MakeFolderSafe(SaveFolder())
	TeamedEntites.resize(8)
	ResetMiniEntity()
	for x in TeamedEntites.size(): TeamedEntites[x] = {}

func _ready() -> void:
	AddConsol()
	AddEnv()

func _notification(what: int) -> void:
	if what in [NOTIFICATION_WM_MOUSE_EXIT, NOTIFICATION_WM_MOUSE_ENTER, NOTIFICATION_WM_GO_BACK_REQUEST, NOTIFICATION_WM_FOCUS_OUT, NOTIFICATION_WM_FOCUS_IN, NOTIFICATION_WM_QUIT_REQUEST]:
		emit_signal("esc_warnning")
		Save()


func ChangePhotons(delta : float) -> void:
	Photons += delta
	emit_signal("inventory_changed", ITEMS.PHOTONS)

func ChangeStarDust(delta : float) -> void:
	StarDust += delta
	emit_signal("inventory_changed", ITEMS.STAR_DUST)

func LevelupCost(from : int = Level) -> float: return (from + 1) * 1000.0

func ChangeXp(delta : float) -> void:
	Xp += delta
	while Xp >= LevelupCost():
		Xp -= LevelupCost()
		Level += 1
		emit_signal("inventory_changed", ITEMS.LEVEL)
	emit_signal("inventory_changed", ITEMS.XP)



func OnDataLoaded() -> void:
	for x in DataManger.Levels:
		if x in LevelsStats: continue
		LevelsStats[x] = {
			won = false,
			played_times = 0,
			time_playing = 0,
			loot_gained = {
				photon = 0,
				stardust = 0,
				xp = 0
			},
			best_wave = 0,
			kills = {}
		}
	
	for x in DataManger.Entites:
		if x in CherctersData: continue
	
	
	call_deferred("Load")

func AddConsol() -> void:
	var p := CanvasLayer.new()
	p.layer = 2
	add_child(p)
	p.add_child(ConsolPanel)
	ConsolPanel.visible = false

func AddEnv() -> void:
	GlobalWorldEnvironment.environment = GlobalEnvironment
	add_child(GlobalWorldEnvironment)
	
	BGLayer.layer = -1
	add_child(BGLayer)
	BGStars = preload("res://assets/ui/BG.tscn").instance()
	BGLayer.add_child(BGStars)

func TurnoffPPE() -> void:
	IsPPEEnabled = false
	GlobalWorldEnvironment.environment = null
func TurnonPPE() -> void:
	IsPPEEnabled = true
	GlobalWorldEnvironment.environment = GlobalEnvironment

func _physics_process(delta: float) -> void:
#	if Input.is_action_just_pressed("ui_accept"):
#		if IsPPEEnabled: TurnoffPPE()
#		else: TurnonPPE()
	if Input.is_action_just_pressed("consol"): ConsolPanel.visible = !ConsolPanel.visible

func SetupMainPlayer(p : Player) -> void:
	MainPlayer = p
	MainPlayer.connect("tree_exiting", self, "RemoveMainPlayer")
	MainTeam = MainPlayer.Team
	emit_signal("main_team_changed")
	emit_signal("main_player_set")


func RemoveMainPlayer() -> void:
	if MainPlayer: 
		MainPlayer.disconnect("tree_exiting", self, "RemoveMainPlayer")
	MainPlayer = null
	emit_signal("main_player_removed")

func AddWorldNode(obj : Node) -> void:
	MainWorld.AddWorldObj(obj)

func GetClosestEnemy(team : int, pos : Vector2) -> Entity:
	var best : Entity
	var best_dis : float = 281474976710656
	for x in TeamedEntites[team]:
		if TeamedEntites[team][x].global_position.distance_squared_to(pos) < best_dis:
			best_dis = TeamedEntites[team][x].global_position.distance_squared_to(pos) 
			best = TeamedEntites[team][x]
	return best 

func AddTeamedEntity(t : Entity) -> void:
	for x in TeamedEntites.size():
		if x == t.Team: continue
		TeamedEntites[x][t.UID] = t

func RemoveTeamedEntity(t : Entity) -> void:
	for x in TeamedEntites.size():
		if x == t.Team: continue
		TeamedEntites[x].erase(t.UID)

func ShiftTeamedEntity(from : int, t : Entity) -> void:
	TeamedEntites[from][t.UID] = t
	TeamedEntites[t.Team].erase(t.UID)

func Broudcast(event : Dictionary) -> void:
	if !"type" in event:
		Log.Error("Invalid event with no type: %s" % event)
		return
	emit_signal("broudcast", event)

func RestartProgram() -> void:
	emit_signal("esc_warnning")
	SU.Restart(get_tree())

func Save(to : String = SavePath()) -> void:
	var f := File.new()
	
	var data : Dictionary = {
		lvls = LevelsStats,
		res = {
			photons = Photons,
			stardust = StarDust,
			xp = Xp, lvl = Level
		},
		st = Stats,
		raw = DataManger.RawData
	}
	
	var ts : String = JSON.print(data)
	SU.SaveToFile(to.replace(".bin", ".json"), JSON.print(data, "\t"))
	
	var p : PoolByteArray = ts.to_ascii()
	var psize : int = p.size()
	p = p.compress(2)
	var psize2 : int = p.size()
	p.resize(ceil(p.size() / 16.0) * 16.0)
	var aes : AESContext = AESContext.new()
	aes.start(AESContext.MODE_ECB_ENCRYPT, [1,1,2,3,5,8,13,21,34,55,89,144,233,121,75,91])
	p = aes.update(p)
	aes.finish()
	
	f.open(to, File.WRITE)
	f.store_string("LSF")
	f.store_buffer(VERSION_CTRL.VERSION_ARR)
	f.store_32(psize)
	f.store_32(psize2)
	f.store_32(p.size())
	f.store_buffer(p)
	f.close()

func Load(from : String = SavePath()) -> void:
	var f := File.new()
	FU.MakeFolderSafe(from.get_base_dir())
	if !f.file_exists(from):
		Log.Error("No save file at path: %s" % [from])
		return
	f.open(from, File.READ)
	if f.get_len() <= 18:
		Log.Error("Invalid save file at \"%s\": ERR_TOO_SHORT" % [from])
		return
	var id : String = f.get_buffer(3).get_string_from_ascii()
	if id != "LSF":
		Log.Error("Invalid save file at \"%s\": ERR_UNKNOWN" % [from])
		return
	var version : Array = f.get_buffer(3)
	if !VERSION_CTRL.IsSupportedSaveVersion(version):
		Log.Error("Outdated save file at \"%s\"" % [from])
		return
	var sizes = [f.get_32(), f.get_32(), f.get_32()]
	
	for x in sizes:
		if x <= 0:
			Log.Error("Invalid save file at \"%s\": ERR_INVALID_SIZE" % [from])
			return
	
	var buffer : = f.get_buffer(sizes[2])
	
	var p : PoolByteArray
	
	var aes : AESContext = AESContext.new()
	aes.start(AESContext.MODE_ECB_DECRYPT, [1,1,2,3,5,8,13,21,34,55,89,144,233,121,75,91])
	p = aes.update(buffer)
	aes.finish()
	p.size()
	p.resize(sizes[1])
	
	p = p.decompress(sizes[0], 2)
	
	var js := JSON.parse(p.get_string_from_ascii())
	
	if js.error:
		Log.Error("Error loading file at \"%s\": ERR_FAILED_PARSING" % [from])
		return
	
	if !js.result is Dictionary:
		Log.Error("Error loading file at \"%s\": ERR_INVALID_RESULT" % [from])
		return
	
	var data : Dictionary = js.result
	
	LevelsStats = data.get("lvls", {})
	
	Photons = data.get("res", {}).get("photons", 0)
	StarDust = data.get("res", {}).get("stardust", 0)
	Xp = data.get("res", {}).get("xp", 0)
	Level = data.get("res", {}).get("lvl", 0)
	
	Stats = data.get("st", {})
	
	Log.Massege("Loaded the game save!")
	


func Save_WriteValueToStream(value, stream : BitFrame) -> void:
	stream.write_i8(typeof(value))
	match typeof(value):
		TYPE_NIL: pass
		TYPE_BOOL: stream.write_i8(int(value))
		TYPE_INT: stream.write_i64(value)
		TYPE_REAL:
			stream.write_i8(len(var2bytes(value)))
			stream.write_bytes(var2bytes(value))
		TYPE_STRING:
			stream.write_i16(len(value))
			stream.write_ascii(value)
		TYPE_VECTOR2:
			stream.write_i8(len(var2bytes(value)))
			stream.write_bytes(var2bytes(value))
		TYPE_RECT2:
			stream.write_i8(len(var2bytes(value)))
			stream.write_bytes(var2bytes(value))
		TYPE_COLOR:
			stream.write_i8(value.r8)
			stream.write_i8(value.g8)
			stream.write_i8(value.b8)
			stream.write_i8(value.a8)
		TYPE_DICTIONARY:
			stream.write_i8(len(var2bytes(value)))
			stream.write_bytes(var2bytes(value))
			# Too lazy 😢😢:(
		

func Redirect_CSCPressed(card : ChercterSelectionCard) -> void:
	if BaseMiniWorld:
		BaseMiniWorld.ChercterSeleceted(card)
