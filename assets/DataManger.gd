extends Node
signal progress
signal done
const GAMENAME = "Lavander"
const UNKNOWNERROR = "UNKNOWN_ERROR"
const DEFAULT_RAW = preload("res://missing.png")
const GRAPHICS_CACHE_COMP = 2
const SIMPLE_POLYGONS_RES_COUNT = 5
var DEFAULT_IMAGE : Image = DEFAULT_RAW.get_data()
var DEFAULT : LoadedTexture = LoadedTexture.new(DEFAULT_IMAGE, 1)



# 1.797693134862315907729305190789e+308
const I1024 = "179769313486231590772930519078900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"

const I128 = "340282366920938430000000000000000000000"

static func GAMEDATAFOLDER() -> String: return FU.GameFolder().plus_file(GAMENAME)
static func MODSFOLDER() -> String: return GAMEDATAFOLDER().plus_file("mods")
static func GRAPHICSFOLDER() -> String: return GAMEDATAFOLDER().plus_file("graphics")

static func DATACAHEFILE() -> String: return GAMEDATAFOLDER().plus_file("cache.bin")
static func MODSSETTINGSFILE() -> String: return MODSFOLDER().plus_file("mods.json")

enum {
	FILETYPE_DATA
	FILETYPE_GRAPHICS
	FILETYPE_LIB
}

enum PSTAGE {
	INIT = 1
	MODS_INFO = 2
	MODS_DATA = 3
	PROTOTYPES = 4
}

const WAVECOMPS_SCRIPTS = {
	reward = Reward_WaveComp
}

var ProgressStage : int

var rng := RNG.new()
var RunArgs : Dictionary

var Graphics : Dictionary
var GraphicsCache : Dictionary # HashedRequster:Texture
var BitmapsCache : Dictionary # Id:Bitmap
var ImagesCache : Dictionary

var FloorTileset : GameTileset
var WallsTileset : GameTileset

var Props : Dictionary

# ID: [Player, Bot, Entity]
var EntitesPrototypes : Dictionary
var Entites : Dictionary

var Effects : Dictionary
var Stages : Dictionary
var Levels : Dictionary
var LevelsData : Dictionary

var Projectiles : Dictionary
var SimplePolygons : Dictionary
var Weapons : Dictionary
var Particals : Dictionary

var Mods : Dictionary
var ModsSettings : Dictionary
var RawData : Dictionary
var RawDataGraphics : Dictionary

var Data : Dictionary
var CustomVars : Dictionary
var ModsPreIdPath : Dictionary

var NextParseBuffer : Array

var AvailableNFEs : Dictionary

var MiniworldData : = MiniWorldCache.new()

var WhiteCommentsPattren := REGEX.new("(?<=\\s)//!")

static func IsNum(i) -> bool: return i is float || i is int
func NewRawDataInfo(id : String) -> Dictionary:
	var r : = {
		id = id,
		path = "",
		type = "",
		data = {},
		mod = "",
		order = 0,
		valid = true
	}
	RawData[id] = r
	return r

func _init() -> void:
	var p := OS.get_cmdline_args()
	for x in p.size():
		var sp : Array = p[x].split(" ", false, 2)
		if sp.size() == 1:
			if !"=" in sp[0]:
				RunArgs[CleanRunArg(sp[0])] = null
			else:
				sp = sp[0].split("=", false, 2)
				RunArgs[CleanRunArg(sp[0])] = sp[1]
		else:
			RunArgs[CleanRunArg(sp[0])] = sp[1]
	
	Log.DEPUG = "debug_mode" in RunArgs
	
	FU.MakeFolderSafe(MODSFOLDER())
	FU.MakeFolderSafe(GRAPHICSFOLDER())
	

func _ready() -> void:
	Game.connect("esc_warnning", self, "ESCWarnning")

func CleanRunArg(s : String) -> String: return s.lstrip("-")

# track_info = {
#	id = <string>,
#	subid = <string>,
#	path = <string>,
#}
func LoadGraphics(data : Dictionary, track_info : Dictionary) -> Texture:
	var ihash : int = hash(data)
	if ihash in GraphicsCache: return GraphicsCache[ihash]
	
	var type : int
	if !"type" in data:
		Log.Warning("No type in graphics loader from id \"%s;%s\" path \"%s\", using \"single\" type" % [track_info.id, track_info.subid, track_info.path])
		type = 0
	else:
		if "blit" in data.type: type = 1
		elif "anima" in data.type: type = 2
	
#	if "gid" in data:
#		if data.gid in GraphicsCache: GraphicsCache[data.gid]
#	else:
#		data.gid = rng.rand64()
	
	var offset : Vector2
	if "offset" in data:
		if !data.offset is Dictionary:
			Log.Error("Mistyped field \"offset\" wich should be an object field in graphics loader from id \"%s;%s\" path \"%s\"" % [track_info.id, track_info.subid, track_info.path])
		elif !data.offset.has_all(["x", "y"]):
			Log.Error("Invalid field \"offset\" wich should have an \"x\" and \"y\" elements in graphics loader from id \"%s;%s\" path \"%s\"" % [track_info.id, track_info.subid, track_info.path])
		elif !IsNum(data.offset.x):
			Log.Error("Invalid field \"offset.x\" wich should be a NUMPER in graphics loader from id \"%s;%s\" path \"%s\"" % [track_info.id, track_info.subid, track_info.path])
		elif !IsNum(data.offset.y):
			Log.Error("Invalid field \"offset.y\" wich should be a NUMPER in graphics loader from id \"%s;%s\" path \"%s\"" % [track_info.id, track_info.subid, track_info.path])
		else:
			offset.x = data.offset.x
			offset.y = data.offset.y
	
	if type < 2:
		if !"path" in data:
			Log.Error("No path in graphics loader from id \"%s;%s\" path \"%s\"" % [track_info.id, track_info.subid, track_info.path])
			return DEFAULT
	
	var img : Image
	
	if type < 2:
		data.path = FU.SimpfyPath(str(data.path))
		if data.path in ImagesCache:
			img = ImagesCache[data.path]
		else:
			img = Image.new()
			var i : int = LoadImage(img, data.path)
			if i:
				Log.Error("failed to load image at path \"%s\" as %s" % [data.path, Exception.ERRORS_IDS[i]])
			else:
				ImagesCache[data.path] = img
	
	
	if type == 0:
		var t : LoadedTexture = LoadedTexture.new(img)
		t.path = data.path
		t.id = track_info.id
		t.subid = track_info.subid
		t.offset = offset
		GraphicsCache[ihash] = t
		return t
	elif type == 1:
		var frame_d : Dictionary
		if !"frame" in data:
			Log.Error("No \"frame\" field in graphics loader from id \"%s;%s\" path \"%s\", frame fields should be: {\"x\" : <NUM>,\"y\" : <NUM>,\"w\" : <NUM>,\"h\" : <NUM>}" % [track_info.id, track_info.subid, track_info.path])
			return DEFAULT
		elif !data.frame is Dictionary:
			Log.Error("Field \"frame\" in graphics loader from id \"%s;%s\" path \"%s\" should be an object" % [track_info.id, track_info.subid, track_info.path])
			return DEFAULT
		elif !data.frame.has_all(["x","y","w","h"]):
			Log.Error("Field \"frame\" in graphics loader from id \"%s;%s\" path \"%s\" should have an x,y,w and h field set to numpers" % [track_info.id, track_info.subid, track_info.path])
			return DEFAULT
		else:
			frame_d = data.frame
			if !(frame_d.x is float || frame_d.x is int):
				Log.Error("Field \"frame.x\" in graphics loader from id \"%s;%s\" path \"%s\" should be a numper" % [track_info.id, track_info.subid, track_info.path])
				return DEFAULT
			if !(frame_d.y is float || frame_d.y is int):
				Log.Error("Field \"frame.y\" in graphics loader from id \"%s;%s\" path \"%s\" should be a numper" % [track_info.id, track_info.subid, track_info.path])
				return DEFAULT
			if !(frame_d.w is float || frame_d.w is int):
				Log.Error("Field \"frame.w\" in graphics loader from id \"%s;%s\" path \"%s\" should be a numper" % [track_info.id, track_info.subid, track_info.path])
				return DEFAULT
			if !(frame_d.h is float || frame_d.h is int):
				Log.Error("Field \"frame.h\" in graphics loader from id \"%s;%s\" path \"%s\" should be a numper" % [track_info.id, track_info.subid, track_info.path])
				return DEFAULT
		var frame : Rect2 = Rect2(frame_d.x, frame_d.y, frame_d.w, frame_d.h)
		var t := LoadedTexture.new(img, 7, frame)
		GraphicsCache[ihash] = t
		t.path = data.path
		t.offset = offset
		t.id = track_info.id
		t.subid = track_info.subid
		return t
	elif type == 2:
		if !"frames" in data:
			Log.Error("No \"frames\" field in graphics loader from id \"%s;%s\" path \"%s\", frames fields should be: {\"x\" : <NUM>,\"y\" : <NUM>,\"w\" : <NUM>,\"h\" : <NUM>}" % [track_info.id, track_info.subid, track_info.path])
			return DEFAULT
		elif !data.frames is Array:
			Log.Error("Field \"frames\" in graphics loader from id \"%s;%s\" path \"%s\" should be an array" % [track_info.id, track_info.subid, track_info.path])
			return DEFAULT
		
		var ani : LoadedAnimation = LoadedAnimation.new()
		ani.frames = data.frames.size()
		
		for x in data.frames.size():
			var tp : Dictionary = track_info.duplicate(true)
			tp.subid += "." + str(x)
			var p : Texture = LoadGraphics(data.frames[x], tp)
			ani.set_frame_texture(x, p)
		
		if "fps" in data:
			if !ParseUtility.IsNum(data.fps):
				Log.Warning("Field \"frames\" in graphics loader from id \"%s;%s\" path \"%s\" should be a numper" % [track_info.id, track_info.subid, track_info.path])
				data.fps = 24
			ani.fps = data.fps
		GraphicsCache[ihash] = ani
		ani.id = track_info.id
		ani.subid = track_info.subid
		return ani
	
	return DEFAULT

func LoadImage(img : Image, at : String) -> int:
	at = FU.SimpfyPath(at)
	if at in ImagesCache:
		img = ImagesCache[at]
		return 0
	var i : int = img.load(at)
	ImagesCache[at] = img
	return i


func GetGraphics(id : String, default : Texture = null) -> Texture: return Graphics.get(id, default)
func GetGraphicsSafe(id : String, default : Texture = DEFAULT_RAW) -> Texture: return Graphics.get(id, default)
func GetBitmap(id : String, default : bool = true) -> BitMap:
	var p : Texture = GetGraphics(id)
	var bit : = BitMap.new()
	
	if id in BitmapsCache: return BitmapsCache[id]
	
	if !p:
		bit.create(Vector2.ONE * 4)
		bit.set_bit_rect(Rect2(0,0,4,4), default)
		return bit
	
	bit.create_from_image_alpha(p.get_data(), 0.5)
	BitmapsCache[id] = bit
	
	return bit

static func ApplyGraphics_TextureButton(t : TextureButton, id : String) -> void:
	t.texture_normal = DataManger.GetGraphics(id + ".normal")
	t.texture_hover = DataManger.GetGraphics(id + ".hovered")
	t.texture_pressed = DataManger.GetGraphics(id + ".pressed")
	t.texture_disabled = DataManger.GetGraphics(id + ".disabled")
	t.texture_click_mask = DataManger.GetBitmap(id + ".mask")

func StartLoading() -> GDScriptFunctionState:
	var time := OS.get_ticks_usec()
	var mem := MemoryTracker.new()
	InitLoading()
	yield(BuildModsInfo(), "completed")
	yield(get_tree(), "idle_frame")
	yield(BuildModsData(), "completed")
	yield(get_tree(), "idle_frame")
	
	yield(CheckCaches_Late(), "completed")
	
	yield(get_tree(), "idle_frame")
	yield(BuildPrototypes(), "completed")
	SU.SaveToFile(GAMEDATAFOLDER().plus_file("mods.json"), JSON.print(Mods, "\t"))
	SU.SaveToFile(GAMEDATAFOLDER().plus_file("raw_data.json"), JSON.print(RawData, "\t"))
	emit_signal("done")
	
	Game.ConsolPanel.OnDoneLoading()
	
#	OSTools.Open(GAMEDATAFOLDER())
	OS.clipboard = GAMEDATAFOLDER()
	
	ReferenceBirdge.OnDataLoaded()
	Game.OnDataLoaded()
	
	SaveGraphicsCache()
	
#	BuildAtlas(ImagesCache.values(), 1024).save_png("res://atlas.png")
	
	Log.Massege("Done loading data in %sms and used %skb of static memory and %skb of dynamic memory" % [time / 1000.0, stepify(mem.Usage(mem.USAGE_KILOBYTE), 0.1), stepify(mem.Usage(mem.USAGE_KILOBYTE, true), 0.1)])
	call_deferred("SaveModSettings")
	return

func InitLoading() -> void:
	
	var nfe_script : Array = FU.SearchFolder("res://assets/scripts/nfe", "gd", true)
	
	for i in nfe_script:
		var gd : GDScript = load(i)
		if !gd: continue
		var obj : Object = gd.new()
		if obj.has_method("TypeID"): AvailableNFEs[obj.TypeID()] = gd
	
	SimplePolygons = BuildSimplePolys()
	Log.DebugMassege(SimplePolygons)
	
	var base : = Node2D.new()
	
	var pos : Vector2
	for x in SimplePolygons:
		
		if SimplePolygons[x] is Array:
			for i in SimplePolygons[x].size():
				var p : Polygon2D = SimplePolygons[x][i].instance()
				p.name = x + "." + str(i)
				p.position = pos; pos += Vector2(32,0)
				base.add_child(p)
		elif SimplePolygons[x] is PackedScene:
			var p : Polygon2D = SimplePolygons[x].instance()
			p.name = x
			p.position = pos; pos += Vector2(32,0)
			base.add_child(p)
	
	SU.ApplyOwner(base,base)
	SaveRes("temp/polygons.tscn", SU.PackNode(base))
	
	ProgressStage = PSTAGE.INIT

func BuildModsInfo() -> GDScriptFunctionState:
	yield(get_tree(), "idle_frame")
	var verison_regex := RegEx.new()
	verison_regex.compile("\\d+")
	emit_signal("progress", "Loading mods", 0)
	var folders : Array = FU.SearchFolder(MODSFOLDER(), "", false)
	for x in folders.size():
		yield(get_tree(), "idle_frame")
		emit_signal("progress", "Loading mods", 10.0 / folders.size())
		var info_path : String = folders[x].plus_file("info.json")
		var info : Dictionary = ParseModsInfo(info_path)
		
		if !"id" in info:
			Log.Error("\"id\" field is required in \"%s\"" % [info_path])
			continue
		if !"version" in info:
			Log.Error("\"version\" field is required in \"%s\"" % [info_path])
			continue
		else:
			info.version_text = info.version
			info.version = ParseVersion(info.version as String, verison_regex,{fail_error = "\"version\" field should have the pattren \"major.minor.patch\" in \"%s\"" % [info_path]})
		
		if !"game_versions" in info || !info.game_versions is Array: info.game_versions = []
		else:
			for i in info.game_versions.size():
				info.game_versions[i] = ParseVersion(info.game_versions[i] as String, verison_regex,{fail_error = "\"game_versions\" field should have the pattren \"major.minor.patch\" for all its elements (%s:%s) in \"%s\"" % [i, info.game_versions[i], info_path]})
		
		if "game_version" in info:
			info.game_versions.append(ParseVersion(info.game_version as String, verison_regex,{fail_error = "\"game_version\" field should have the pattren \"major.minor.patch\" in \"%s\"" % [info_path]}))
		info.author = info.get("author", "unknwon") as String
		info.name = info.get("name", info.id) as String
		info.desc = info.get("desc", "unkown") as String
		
		info.path = folders[x]
		info.files = FU.CatorgraizedFilesSearch(folders[x], [], true)
		
		info.enabled = true
		info.piority = 0
		
		info.loaded = false
		
		Mods[info.id] = info
		ModsPreIdPath["__%s__"%info.id] = folders[x]
	
	var f : File = File.new()
	if f.file_exists(MODSSETTINGSFILE()):
		f.open(MODSSETTINGSFILE(), File.READ)
		var text : String = f.get_as_text()
		f.close()
		var js := JSON.parse(text)
		
		if js.error:
			Log.Error("Failed loading mods settings")
		elif !js.result is Dictionary:
			Log.Error("Failed loading mods settings")
		else:
			ModsSettings = js.result
			for x in Mods:
				if x in ModsSettings:
					Mods[x].enabled = ModsSettings[x].get("enabled", true)
	else:
		Log.Error("Failed loading mods settings")
	ProgressStage = PSTAGE.MODS_INFO
	
	return

func BuildModsData() -> GDScriptFunctionState:
	yield(get_tree(), "idle_frame")
	var order : int
	
	var current_path : String
	emit_signal("progress", "Loading data", 0.0)
	
	var ix : float = Mods.size()
	for x in Mods:
		emit_signal("progress", "Loading data", 25.0 / ix)
		current_path = Mods[x].path
		Mods[x].data = []
		if !Mods[x].get("enabled", true): continue
		Mods[x].loaded = true
		
		var files : Dictionary = Mods[x].files
		for i in files.get("json", []).size():
			emit_signal("progress", "Loading data: %s" % files.json[i], 0)
			yield(get_tree(), "idle_frame")
			if files.json[i].get_file().to_lower() == "info.json": continue
			Mods[x].data.append(ParseJsonData(files.json[i], x, {folder = current_path}))
	
	yield(get_tree(), "idle_frame")
	for x in NextParseBuffer:
		emit_signal("progress", "Loading data: %s" % [x.path], 15.0 / NextParseBuffer.size())
		yield(get_tree(), "idle_frame")
		Mods[x.mod].data.append(ParseBufferElement(x))
	
	ProgressStage = PSTAGE.MODS_DATA
	
	return

func CheckCaches_Late() -> GDScriptFunctionState:
	yield(get_tree(), "idle_frame")
	
	var data : Dictionary = LoadGraphicsCache()
	
	emit_signal("progress", "Loading caches: Graphics", 0.0)
	
	for x in data:
#		yield(get_tree(), "idle_frame")
		var img : Texture
		if data[x].get("type") == "blit": img = LoadedTexture.new()
		if !img: continue
		GraphicsCache[x] = img.Recompile(data[x])
	
	emit_signal("progress", "Loading caches: Graphics", 0.0)
	
	return

func BuildPrototypes() -> GDScriptFunctionState:
	yield(get_tree(), "idle_frame")
	
	emit_signal("progress", "Processing prototypes", 0.0)
	var fi : float = RawData.size()
	var ii : int = 0
	
	for x in RawData:
		emit_signal("progress", "Processing prototypes", 15.0 / fi)
		CheclCopyRecrusive(RawData[x], RawData[x]["#path"], RawData[x]["#id"])
	
	if Log.DEPUG:
		FU.MakeFolderSafe("temp/prototypes/effects")
		FU.MakeFolderSafe("temp/prototypes/entites")
	
	FU.MakeFolderSafe("temp/prototypes/entites")
	
	for i in RawDataGraphics:
		var istr : String = str(i)
		if istr.begins_with("#") || istr.begins_with("$") || i == "type": continue
#		print(RawDataGraphics[i])
		Graphics[istr] = LoadGraphics(RawDataGraphics[i], {id = RawDataGraphics[i]["#id"], subid = i, path = RawDataGraphics[i]["#path"]})
	
	for s in 4:
		for x in RawData:
			ii += 1
			emit_signal("progress", "Buidling prototype: %s" % RawData[x]["#id"], 25.0 / fi)
			yield(get_tree(), "idle_frame")
			if !"type" in RawData[x]:
				Log.Warning("No \"type\" field found for data at \"%s\" id \"%s\" mod \"%s\"" % [RawData[x]["#path"], RawData[x]["#id"], RawData[x]["#mod"]])
				continue
			var data : Dictionary = RawData[x]
			var type : String = (data.type as String).strip_edges().left(6).to_lower()
			
			if s == 2 && type == "entity":
				var e := EntityData.new()
				e.mod = data["#mod"]
				e.path = data["#path"]
				e.id = data["#id"]
				e.Construct(data)
				
				Entites[e.id] = e
				var pe := BuildEntityProtoType(Entity, e.id)
				var pp := BuildEntityProtoType(Player, e.id)
				var pb := BuildEntityProtoType(BOT, e.id)
				
				EntitesPrototypes[e.id] = [pp, pb, pe]
				
				if Log.DEPUG: SaveRes("temp/prototypes/entites/%s.player.tscn" % x, pp)
			elif s == 0:
				
				if type == "effect":
					var e : NuzzleFireEffect = AvailableNFEs.get(data.get("instance_type", ""), SparkNFE).new()
					e.id = data["#id"]
					e.path = data["#path"]
					e.Build(data)
					
					var p := SU.PackNode(e)
					
					Effects[e.id] = p
					
					if Log.DEPUG: SaveRes("temp/prototypes/effects/%s.tscn" % x, p)
	#			elif s == 1:
	#				var e := WeaponData.new()
	#				e.mod = data["#mod"]
	#				e.path = data["#path"]
	#				e.id = data["#id"]
	#				e.Construct(data)
	#
	#				var b := BaseWeapon.new()
	#				b.id = e.id
	#				b.data = e
	#				b.Construct()
	#
	#				var p := SU.PackNode(b)
	#
	#				Weapons[e.id] = p
	#
	#				if Log.DEPUG: SaveRes("temp/prototypes/effects/%s.tscn" % x, p)
					
#				elif type == "graphics":
#					for i in data:
#						var istr : String = str(i)
#						if istr.begins_with("#") || istr.begins_with("$") || i == "type": continue
#						Graphics[istr] = LoadGraphics(data[i], {id = data["#id"], subid = i, path = data["#path"]})
#					print(Graphics)
				
			elif s == 3 && type == "level":
				var e := LevelData.new()
				e.mod = data["#mod"]
				e.path = data["#path"]
				e.id = data["#id"]
				e.Construct(data)
				
				LevelsData[e.id] = e
				
				var b := LevelPinPoint.new()
				b.id = e.id
				b.data = e
				b.Construct()
				
				
				var p := SU.PackNode(b)
				
				Levels[e.id] = p
				
				if Log.DEPUG: SaveRes("temp/prototypes/effects/%s.tscn" % x, p)
			
	
	MiniWorld.BuildWorld()
	
	ProgressStage = PSTAGE.PROTOTYPES
	return

func SaveRes(at : String, r : Resource) -> void:
	r.take_over_path(at); ResourceSaver.save(at, r)

func ESCWarnning() -> void:
	if ProgressStage >= PSTAGE.MODS_INFO:
		SaveModSettings()

func SaveModSettings() -> void:
	for x in Mods:
		ModsSettings[x] = {
			enabled = Mods[x].get("enabled", true),
			piority = Mods[x].get("piority", 0)
		}
	
	SU.SaveToFile(MODSSETTINGSFILE(), JSON.print(ModsSettings, "\t"))

func BuildEntityProtoType(script : GDScript, id : String) -> PackedScene:
	var p := PackedScene.new()
	var g : Entity = script.new()
	g.id = id
	g.Construct()
	g.HasLoaded = true
	p.pack(g)
	return p

func ParseBufferElement(b : Dictionary) -> Dictionary:
	var db : Dictionary = b.data.duplicate(true)
	db.merge({buffer = true})
	return ParseJsonData(b.path, b.mod, db)

func ParseJsonData(path : String, mod : String, data : Dictionary) -> Dictionary:
	var res : Dictionary = {error = OK}
	var f := File.new()
	if !f.file_exists(path):
		Log.Error("No file at path \"%s\"" % [path])
		return {error = ERR_FILE_NOT_FOUND}
	f.open(path, File.READ)
	var ts := f.get_as_text()
	f.close()
	ts = InsertCustomVars(ts, mod)
	
	var js := JSON.parse(ts)
	
	if js.error:
		if !"buffer" in data:
			NextParseBuffer.append({mod = mod, path = path, data = data})
			return {}
		Log.Error("json file at path \"%s\" has a parse error at line %s as %s\n\n%s" % [path, js.error_line, js.error_string, NumperLines(ts.replace("\t","    "))])
		return {error = ERR_PARSE_ERROR, js_err = js.error, js_line = js.error_line, js_text = js.error_string}
	if !js.result is Dictionary:
		Log.Error("json file at path \"%s\" should be an object base (aka {})" % [path])
		return {error = ERR_INVALID_DATA}
	
	var type : int
	
	res = js.result
	if !"$type" in res:
		type = FILETYPE_DATA # For now
	elif "data" in res["$type"]: type = FILETYPE_DATA
	elif "graphics" in res["$type"]:
		type = FILETYPE_GRAPHICS
	elif "lib" in res["$type"]: type = FILETYPE_LIB
	else:
		Log.Error("json file at path \"%s\" has an invalid field \"$type\" wich should be one of the following:\n    data, graphics, lib" % [path])
		return {error = ERR_CANT_RESOLVE}
	
	if type == FILETYPE_DATA:
		if !"buffer" in data:
			NextParseBuffer.append({mod = mod, path = path, data = data})
			return {}
		
		for xraw in res:
			var x : String = str(xraw)
			if x.begins_with("$") || x.begins_with("#"): continue
			var cont : Dictionary = res[xraw]
			cont["#mod"] = mod
			cont["#id"] = xraw
			cont["#path"] = path
			RawData[xraw] = cont
	elif type == FILETYPE_GRAPHICS:
		if !"buffer" in data:
			NextParseBuffer.append({mod = mod, path = path, data = data})
			return {}
		
		var data_list : Array
		
		for x in res:
			data_list.append({id = x, name = x, raw = res[x]})
		
		while data_list:
			var data_l0:Dictionary = data_list.pop_back()
			var raw = data_l0.raw
			var x : String = data_l0.id
			if x.begins_with("$") || x.begins_with("#"): continue
			if data_l0.name.begins_with("@"):
				if raw is Dictionary:
					for i in raw:
						data_list.append({id = ParseUtility.AddKey(x, i), name = i, raw = raw[i]})
				elif raw is Array:
					for i in raw.size():
						data_list.append({id = ParseUtility.AddKey(x, str(i)), name = str(i), raw = raw[i]})
				else:
					Log.Error("Invalid graphics tree as any field id that starts with \"@\" is a tree and tree are only OBJECTS or ARRAYS at field \"%s\" at path \"%s\"" % [data_l0.id, path])
				continue
			if !raw is Dictionary:
				Log.Error("Graphics field \"%s\" is not an OBJECT at path \"%s\"" % [data_l0.id, path])
				continue
			var cont : Dictionary = raw
			cont["#mod"] = mod
			cont["#id"] = x
			cont["#path"] = path
			RawDataGraphics[x.replace("@","")] = cont
	else:
		for xraw in res:
			var x : String = str(xraw)
			if x.begins_with("$") || x.begins_with("#"): continue
			NewVar(x, res[xraw], mod)
	
	return res

func CheclCopyRecrusive(data : Dictionary, path : String, id : String, stack : int = 0) -> void:
	if !data.get("#copy_from", "--none--") in id: data = CheckCopy(data, "At \"%s\" id \"%s\"" % [path, id], stack)
	for x in data:
		if data[x] is Dictionary:
			CheclCopyRecrusive(data[x], path, ParseUtility.AddKey(id, x), stack + 1)
		elif data[x] is Array:
			for i in data[x].size():
				if data[x][i] is Dictionary:
					CheclCopyRecrusive(data[x][i], path, ParseUtility.AddKey(id, str(i)), stack + 1)

func CheckCopy(data : Dictionary, tracer : String, stack_size : int = 0) -> Dictionary:
	if stack_size >= 512: return data
	if "#copy_from" in data:
		if data["#copy_from"] is String: data = DataManger.CopyData(data, str(data["#copy_from"]))
		else: Log.Error("field \"#copy_from\" should be the data id(string) to copy from, %s" % [tracer])
	return data

func CopyData(data : Dictionary, from : String) -> Dictionary:
#	var from_mod : String = ""
#	if "#mod" in data: from_mod = data["#mod"]
#
#	if from.begins_with("@"):
#		var i : int = from.find(":")
#		if 0 > i:
#			Log.Error("Can't copy data from \"\" becuse there is an \"@\" with no mod source (e.g. \"@ExMod:ExID\")")
#			data.merge({"#copy_fail" : "invalid_mod_source"}, true)
#			return data
#		if Log.DEBUG: Log.Massege(from, from.substr(1, i - 1).strip_edges(), from.right(i + 1).strip_edges())
#
#	if from_mod:
#		data.merge(Mods[from_mod].data.get(from, {}))
#	else: data.merge(RawData.get(from, {}))
	data.merge(RawData.get(from, {}))
	return data

func InsertCustomVars(s : String, mod : String) -> String:
	s = FU.RemoveComments(WhiteCommentsPattren.sub(s, "", true))
	
	for x in ModsPreIdPath: s = s.replace(x, ModsPreIdPath[x])
	
	for x in CustomVars:
		if mod == CustomVars[x].mod: s = CustomVars[x].regex.sub(s, CustomVars[x].value, true)
		else: s = CustomVars[x].regex_m.sub(s, CustomVars[x].value, true)
	return s

func NewVar(id : String, value, mod : String) -> void:
	if "\n" in id || " " in id || "\t" in id:
		Log.Error("libs ids should have no whitespaces. ecpacialy \"%s\" in mod \"%s\"" % [id, mod])
		return
#	CustomVars[id] = {value = var2str(value), regex = REGEX.new("(?<!&)&%s(?=\\W)" % [id]), mod = mod, regex_m = REGEX.new("(?<!&)&%s.%s(?=\\W)" % [mod,id])}
	CustomVars[id] = {value = var2str(value), regex = REGEX.new("\"{%s}\"" % [id]), mod = mod, regex_m = REGEX.new("\"{%s.%s}\"" % [mod,id])}

func ParseVersion(p : String, r : RegEx, data : Dictionary = {}) -> int:
	var v := r.search_all(p)
	if v.size() < 3:
		Log.Error(data.get("fail_error", UNKNOWNERROR))
		return -1
	else:
		return ((v[0].strings[0] as int % 256) * 65536) + ((v[1].strings[0] as int % 256) * 256 ) + (v[2].strings[0] as int % 256)

func ParseModsInfo(path : String) -> Dictionary:
	var f := File.new()
	if !f.file_exists(path):
		return {failed = true, error = ERR_FILE_NOT_FOUND}
	var err : int = f.open(path, File.READ)
	if err:
		return {failed = true, error = err}
	var s : String = f.get_as_text()
	f.close()
	var json := JSON.parse(s)
	if json.error: return {failed = true, error = json.error, json = true, line = json.error_line, err_text = json.error_string, text = s}
	return json.result

func MakeSafeGDScript(source : String) -> Dictionary:
	var b:= GDScript.new()
	source.replace("OS", "system")
	var fill_s : String = FU.RemoveComments(source, "#")
	if "Script" in fill_s: return {error = "script_found"}
	source = "extends SafeGD\n" + source
	b.source_code = source
	var i := b.reload()
	if i: return {error = "error_%s" % [Exception.ERRORS_IDS[i]]}
	return {gd = b}


func Json2Bin(js : Dictionary) -> PoolByteArray:
	var b := BitFrame.new()
	b.write_i32(VERSION_CTRL.VERSION())
	var i0 : int = b.index
	b.write_ascii("jb")
	for x in js:
		assert(!x is Dictionary && !x is Array && !x is Object, "Object keys can not be containers for sub data")
		assert(!x is String || x.length() < 248, "String keys can not pass 248 in length")
		b.write_i8(var2bytes(x).size())
		b.write_bytes(var2bytes(x))
		b.write_ascii(".")
		var s := var2bytes(js[x])
		b.write_i16(s.size())
		b.write_bytes(s)
		b.write_ascii("'")
	
	
	return b.bytes


func CompileData(data : Dictionary) -> PoolByteArray:
	var pr : PoolByteArray
	pr = var2bytes(data)
	pr = pr.compress(2)
	pr.resize(ceil(pr.size() / 16.0) * 16)
	var p : AESContext = AESContext.new()
	p.start(AESContext.MODE_ECB_ENCRYPT, [22,44,32,13,91,23,55,210,144,88,222,200,1,99,27,255])
	pr = p.update(pr)
	p.finish()
	var hs : = hash(data)
	
	var hss := PoolByteArray([hs >> 24, (hs >> 16) && 0xff, (hs >> 8) & 0xff, hs & 0xff])
	hss.invert()
	pr = PoolByteArray( [76, 67, 68] ) + PoolByteArray(VERSION_CTRL.VERSION_ARR) + hss + pr
	SU.SaveToFile(GAMEDATAFOLDER().plus_file("compiled.bin"), pr)
	return pr

func SaveGraphicsCache() -> void:
	var g_data :Dictionary
	
	for i in GraphicsCache:
		if !GraphicsCache[i]: continue
		g_data[i] = GraphicsCache[i].Data()
	var p : PoolByteArray = var2bytes(g_data)
	var f : = File.new()
	f.open(GAMEDATAFOLDER().plus_file("graphics.dat"), File.WRITE)
	f.store_32(p.size())
	p = p.compress(GRAPHICS_CACHE_COMP)
	f.store_32(p.size())
	f.store_buffer(p)
	f.close()

func LoadGraphicsCache() -> Dictionary:
	var x : PoolByteArray = SU.GetFileContents(GAMEDATAFOLDER().plus_file("graphics.dat"), [0,0,0,0], SU.FILE_CONTENT_TYPE.STREAM)
	var bit : = BitFrame.new(x)
	var size : int = bit.read_iu32()
	var size_2 : int = bit.read_iu32()
	if size <= 0 || size_2 <= 0:
		Log.Error("Invalid graphics cache, %d %d" % [size, size_2])
		return {}
	var p : PoolByteArray = bit.read_bytes(size_2)
	p = p.decompress(size, GRAPHICS_CACHE_COMP)
	return {}
	return bytes2var(p)

static func NumperLines(t : String) -> String:
	var l : int
	var c : int = 1
	while true:
		l = t.find("\n", l)
		if l == -1: break
		t = t.insert(l+1, str(c) + "  ")
		l += len(str(c) + "  ") + 1
		c += 1
	return t

static func BuildAtlas(images : Array, width : int) -> Image:
	var lines : int
	var line_start : int
	var line_size : int
	var current_w : int
	var res := AtlasImage.new()
	var hight : int
	
	for x in images.size():
		var im : Image = images[x]
		if current_w + im.get_width() > width:
			res.AddImage(current_w, line_start, im)
			current_w += im.get_width()
			line_size = max(line_size, im.get_height())
		else:
			line_start += line_size
			line_size = im.get_height()
			lines += 1
			current_w = im.get_width()
			res.AddImage(0, line_start, im)
	hight = line_start + line_size
	
	res.create(width, hight + 1, false, Image.FORMAT_RGBA8)
	
	for x in res.images:
		res.blit_rect(x.img, Rect2(0,0,x.img.get_width(),x.img.get_hight()), x.position())
	
	return res

static func GetWaveCompScript(comp : String) -> GDScript:
	return WAVECOMPS_SCRIPTS.get(comp, Base_WaveComp)

static func BuildSimplePolys() -> Dictionary:
	var d : Dictionary
	var poly : Polygon2D
	var arr : Array
	var points := PoolVector2Array()
	
	# circles:
	arr = []
	for i in 5:
		
		
		poly = Polygon2D.new()
		points = []
		var points_c : float = 16.0 * (i + 1)
		
		for x in points_c:
			points.append(Vector2.UP.rotated((x / points_c) * TAU) * 16)
		
		poly.polygon = points
		
		arr.append(SU.PackNode(poly))
	d["circle"] = arr
	
	
	# Squares:
	arr = []
	for i in 1:
		
		
		poly = Polygon2D.new()
		
		poly.polygon = PoolVector2Array(
			[
				Vector2(-16,-16), Vector2(-16, 16),
				Vector2(16,16), Vector2(16, -16)
			]
		)
		
		
		d["square"] = SU.PackNode(poly)
	
	# tringles:
	arr = []
	for i in 1:
		
		
		poly = Polygon2D.new()
		
		poly.polygon = PoolVector2Array(
			[
				Vector2(0,-16), Vector2(-16, 16), Vector2(16,16)
			]
		)
		
		d["tringle"] = SU.PackNode(poly)

	
	
	if true:
		d["default"] = null
	
	
	# Rebuild:
#	var data : Dictionary
#	for x in d:
#		for i in d[x].size():
#			data[x + "." + str(i)] = d[x][i]
	
	
#	return data
	return d

func ParseIfPolygon(data : Dictionary, trace : Dictionary) -> Polygon2D:
	if "type" in data:
		if "poly" in str(data.type):
			return ParsePolygon(data, trace)
	return null

func ParsePolygon(data : Dictionary, trace : Dictionary) -> Polygon2D:
	var p : PackedScene = GetPolygon(
		ParseUtility.CheckForString("id", data, trace.link, {trace_id = ParseUtility.AddKey(trace.id, "id"), default = "square", inputs = SimplePolygons.keys()}),
		ParseUtility.CheckForNumper("res", data, trace.link, {trace_id = ParseUtility.AddKey(trace.id, "res"), default = 0}),
		trace
	)
	if p == null: return null
	var poly : Polygon2D = p.instance()
	
	if "size" in data: poly.scale = (ParseUtility.CheckForNumper("size", data, trace.link, {trace_id = ParseUtility.AddKey(trace.id, "size"), default = 1.0}) / 16.0) * Vector2.ONE
	if "width" in data: poly.scale.x = ParseUtility.CheckForNumper("width", data, trace.link, {trace_id = ParseUtility.AddKey(trace.id, "width"), default = 1.0}) / 16.0
	if "hight" in data: poly.scale.y = ParseUtility.CheckForNumper("hight", data, trace.link, {trace_id = ParseUtility.AddKey(trace.id, "hight"), default = 1.0}) / 16.0
	if "color" in data: poly.color = ParseUtility.CheckForColor("color", data, trace.link, {trace_id = ParseUtility.AddKey(trace.id, "color"), default = Color.white})
	if "offset" in data: poly.position = ParseUtility.CheckForVector2("offset", data, trace.link, {trace_id = ParseUtility.AddKey(trace.id, "offset"), default = Vector2.ZERO})
	if "rotation" in data: poly.rotation = deg2rad(ParseUtility.CheckForNumper("rotation", data, trace.link, {trace_id = ParseUtility.AddKey(trace.id, "rotation"), default = 0.0}))
	
	return poly

func GetPolygon(id : String, res : int = 0, trace : Dictionary = {}) -> PackedScene:
	if !id in SimplePolygons:
		Log.Error("No polygon with id \"%s\". requsted from \"%s->%s\"" % [trace.get("id", id), trace.get("mod","UNKNWON"), trace.get("path", "UNKNWON")])
		return SimplePolygons.default
	if SimplePolygons[id] is Array:
		if SimplePolygons[id].size() <= res:
			Log.Error("No polygon resloution with index \"%s\" with id \"%s\". requsted from \"%s->%s\"" % [res, trace.get("id", id), trace.get("mod","UNKNWON"), trace.get("path", "UNKNWON")])
			return SimplePolygons.default
		return SimplePolygons[id][res]
	return SimplePolygons[id]

func BuildParticales(data : Dictionary, trace : Dictionary) -> CPUParticles2D:
	var cpu : = CPUParticles2D.new()
	
	if "amount" in data: cpu.amount = ParseUtility.CheckForNumperPositiveNonzeroI("amount", data, trace.link, {trace_id = trace.id + ".amount", default = cpu.amount})
	if "lifetime" in data: cpu.lifetime = ParseUtility.CheckForNumperPositiveNonzero("lifetime", data, trace.link, {trace_id = trace.id + ".lifetime", default = cpu.lifetime})
	if "one_shot" in data: cpu.one_shot = ParseUtility.CheckForBool("one_shot", data, trace.link, {trace_id = trace.id + ".one_shot", default = cpu.one_shot})
	if "preprocess" in data: cpu.preprocess = ParseUtility.CheckForNumperPositive("preprocess", data, trace.link, {trace_id = trace.id + ".preprocess", default = cpu.preprocess})
	if "speed_scale" in data: cpu.speed_scale = ParseUtility.CheckForNumperPositiveNonzero("speed_scale", data, trace.link, {trace_id = trace.id + ".speed_scale", default = cpu.speed_scale})
	if "explosiveness" in data: cpu.explosiveness = ParseUtility.CheckForNumperPositive("explosiveness", data, trace.link, {trace_id = trace.id + ".explosiveness", default = cpu.explosiveness})
	if "randomness" in data: cpu.randomness = ParseUtility.CheckForNumperPositive("randomness", data, trace.link, {trace_id = trace.id + ".randomness", default = cpu.randomness})
	if "lifetime_randomness" in data: cpu.lifetime_randomness = ParseUtility.CheckForNumperPositive("lifetime_randomness", data, trace.link, {trace_id = trace.id + ".lifetime_randomness", default = cpu.lifetime_randomness})
	if "fixed_fps" in data: cpu.fixed_fps = ParseUtility.CheckForNumperPositiveNonzeroI("fixed_fps", data, trace.link, {trace_id = trace.id + ".fixed_fps", default = cpu.fixed_fps})
	if "fract_delta" in data: cpu.fract_delta = ParseUtility.CheckForBool("fract_delta", data, trace.link, {trace_id = trace.id + ".fract_delta", default = cpu.fract_delta})
	if "local_coords" in data: cpu.local_coords = ParseUtility.CheckForBool("local_coords", data, trace.link, {trace_id = trace.id + ".local_coords", default = false})
	if "texture" in data: cpu.texture = LoadGraphics(ParseUtility.CheckForDictionary("texture", data, trace.link, {trace_id = trace.id + ".texture", default = cpu.texture}), {path = trace.path, subid = "texture", id = trace.id})
	if "normalmap" in data: cpu.normalmap = LoadGraphics(ParseUtility.CheckForDictionary("normalmap", data, trace.link, {trace_id = trace.id + ".normalmap", default = cpu.normalmap}), {path = trace.path, subid = "normalmap", id = trace.id})
	
	if "emission_shape" in data: cpu.emission_shape = ParseUtility.CheckForEnum("emission_shape", data, ["po*", "sp*", "re*"], trace.link, {trace_id = trace.id + ".emission_shape", default = cpu.emission_shape})
	if "emission_sphere_radius" in data: cpu.emission_sphere_radius = ParseUtility.CheckForNumperPositiveNonzero("emission_sphere_radius", data, trace.link, {trace_id = trace.id + ".emission_sphere_radius", default = cpu.emission_sphere_radius})
	if "emission_rect_extents" in data: cpu.emission_rect_extents = ParseUtility.CheckForVector2("emission_rect_extents", data, trace.link, {trace_id = trace.id + ".emission_rect_extents", default = cpu.emission_rect_extents})
	
	if "align_y" in data: cpu.flag_align_y = ParseUtility.CheckForBool("align_y", data, trace.link, {trace_id = trace.id + ".align_y", default = cpu.flag_align_y})
	if "direction" in data: cpu.direction = ParseUtility.CheckForVector2("direction", data, trace.link, {trace_id = trace.id + ".direction", default = cpu.direction})
	elif "dir" in data: cpu.direction = ParseUtility.CheckForVector2("dir", data, trace.link, {trace_id = trace.id + ".dir", default = cpu.direction})
	
	if "spread" in data: cpu.spread = ParseUtility.CheckForNumperPositiveNonzero("spread", data, trace.link, {trace_id = trace.id + ".spread", default = cpu.spread})
	if "gravity" in data: cpu.gravity = ParseUtility.CheckForVector2("gravity", data, trace.link, {trace_id = trace.id + ".gravity", default = Vector2.ZERO})
	
	if "velocity" in data: cpu.initial_velocity = ParseUtility.CheckForNumperPositive("velocity", data, trace.link, {trace_id = trace.id + ".velocity", default = cpu.initial_velocity})
	if "velocity_randomness" in data: cpu.initial_velocity_random = ParseUtility.CheckForNumperPositive("velocity_randomness", data, trace.link, {trace_id = trace.id + ".velocity_randomness", default = cpu.initial_velocity_random})
	if "angular_velocity" in data: cpu.angular_velocity = ParseUtility.CheckForNumperPositive("angular_velocity", data, trace.link, {trace_id = trace.id + ".angular_velocity", default = cpu.angular_velocity})
	if "angular_velocity_randomness" in data: cpu.angular_velocity_random = ParseUtility.CheckForNumperPositive("angular_velocity_randomness", data, trace.link, {trace_id = trace.id + ".angular_velocity_randomness", default = cpu.angular_velocity_random})
	
	if "damping" in data: cpu.damping = ParseUtility.CheckForNumperPositive("damping", data, trace.link, {trace_id = trace.id + ".damping", default = cpu.damping})
	if "damping_randomness" in data: cpu.damping_random = ParseUtility.CheckForNumperPositive("damping_randomness", data, trace.link, {trace_id = trace.id + ".damping_randomness", default = cpu.damping_random})
	
	if "angle" in data: cpu.angle = ParseUtility.CheckForNumper("angle", data, trace.link, {trace_id = trace.id + ".angle", default = cpu.angle})
	if "angle_randomness" in data: cpu.angle_random = ParseUtility.CheckForNumperPositive("angle_randomness", data, trace.link, {trace_id = trace.id + ".angle_randomness", default = cpu.angle_random})
	
	if "scale" in data: cpu.scale_amount = ParseUtility.CheckForNumperPositive("scale", data, trace.link, {trace_id = trace.id + ".scale", default = cpu.scale_amount})
	if "scale_randomness" in data: cpu.scale_amount_random = ParseUtility.CheckForNumperPositive("scale_randomness", data, trace.link, {trace_id = trace.id + ".scale_randomness", default = cpu.scale_amount_random})
	
	if "color" in data: cpu.color = ParseUtility.CheckForColor("color", data, trace.link, {trace_id = trace.id + ".color", default = cpu.color})
	if "color_ramp" in data: cpu.color_ramp = ParseUtility.CheckForGradient("color_ramp", data, trace.link, {trace_id = trace.id + ".color_ramp", default = cpu.color_ramp})
	if "color_spectrum" in data: cpu.color_initial_ramp = ParseUtility.CheckForGradient("color_spectrum", data, trace.link, {trace_id = trace.id + ".color_spectrum", default = cpu.color_initial_ramp})
	
	if "hue" in data: cpu.hue_variation = ParseUtility.CheckForNumper("hue", data, trace.link, {trace_id = trace.id + ".hue", default = cpu.hue_variation})
	if "hue_randomness" in data: cpu.hue_variation_random = ParseUtility.CheckForNumperPositive("hue_randomness", data, trace.link, {trace_id = trace.id + ".hue_randomness", default = cpu.hue_variation_random})
	
	
	
	return cpu
