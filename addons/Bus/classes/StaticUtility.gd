class_name SU extends Object
const FILES = []
const MAX_RERUN = 7

enum FILE_CONTENT_TYPE {
	STREAM
	VARIBLE
	VARIBLE_WITH_OBJ
	STRING
}

enum NUMPER_TYPES {
	NUMPER
	VECTOR2
	VECTOR3
	RECT2
	COLOR
	COLOR_NA # No Alpha
#	TRANSOFRM5 # 1 -> pos.x, 2 -> pos.y, 3 -> rot, 4 -> scale.x, 5 -> scale.y
}

enum NUMPER_FLAGS {
	NUMPER = 1
	VECTOR2 = 2
	VECTOR3 = 4
	RECT2 = 8
	COLOR = 16
	COLOR_NA = 32 # No Alpha
#	TRANSOFRM5 = 64# 1 -> pos.x, 2 -> pos.y, 3 -> rot, 4 -> scale.x, 5 -> scale.y
}

const BYTE2READBLE = "0123456789:;<=>?ABCDEFGHIJKLMNOPQRSTUVWXYZ[]abcdefghijklmnopqrstuvwxyz"

const TYPEOF_NAMES = [
	"nil",
	"bool",
	"int",
	"real",
	"string",
	"vector2",
	"rect2",
	"vector3",
	"transform2D",
	"plane",
	"quat",
	"rect3",
	"basic",
	"transform3D",
	"vector4",
	"path",
	"rid",
	"object",
	"dictionary",
	"array",
	"poolbytes",
	"poolints",
	"poolreals",
	"poolstrings",
	"poolvector2s",
	"poolvector3s",
	"poolvector4s",
	"unknown",
]

func _init() -> void: Exception.StaticViolation("SU")

static func INIT() -> void:
	BuildStaticVars_Files()

static func FillArray(arr : Array, size : int, value) -> Array:
	if size <= arr.size(): return arr
	for x in size - arr.size(): arr.append(value)
	return arr

static func RefAll(obj : Object) -> Dictionary:
	var refs : Dictionary
	var data : Array = obj.get_property_list()
	for x in data:
		refs[x.name] = Ref.new(obj, x.name)
		refs[x.name].value = obj.get(x.name)
		refs[x.name].value_type = x.type
	return refs

static func RefTree(tree : SceneTree) -> Dictionary:
	if !tree: return {}
	var arr : Array = [tree.get_root()]
	var data : Dictionary
	while arr:
		var n : Node = arr.pop_back()
		if !n: continue
		if !n.is_inside_tree(): continue
		data[n.get_path()] = RefAll(n)
		arr.append_array(n.get_children())
	
	return data

static func GetFileContents(path : String, default, type : int = FILE_CONTENT_TYPE.STRING):
	var f : File = File.new()
	if !f.file_exists(path): return default
	f.open(path, f.READ)
	var data
	match type:
		FILE_CONTENT_TYPE.STREAM: data = f.get_buffer(f.get_len())
		FILE_CONTENT_TYPE.VARIBLE: data = f.get_var(false)
		FILE_CONTENT_TYPE.VARIBLE_WITH_OBJ: data = f.get_var(true)
		FILE_CONTENT_TYPE.STRING: data = f.get_as_text()
	f.close()
	return data

## Depricated!
#static func SaveToFile(path : String, data, type : int = FILE_CONTENT_TYPE.STRING) -> void:
#	var f : File = File.new()
#	MakeDir(path.get_base_dir())
#	if f.open(path, f.WRITE):
#		push_error("Failed to set a file contents at '%s', e=%s" % [path, f.open(path, f.WRITE)])
#		return
#	match type:
#		FILE_CONTENT_TYPE.STREAM: f.store_buffer(data)
#		FILE_CONTENT_TYPE.VARIBLE: f.store_var(data, false)
#		FILE_CONTENT_TYPE.VARIBLE_WITH_OBJ: f.store_var(data, true)
#		FILE_CONTENT_TYPE.STRING: f.store_string(data)
#	f.close()

static func SaveToFile(path : String, data, Full : bool = false) -> void:
	var f : File = File.new()
	MakeDir(path.get_base_dir())
	if f.open(path, f.WRITE):
		push_error("Failed to set a file contents at '%s', e=%s" % [path, f.open(path, f.WRITE)])
		return
	if data is PoolByteArray: f.store_buffer(data)
	elif data is String: f.store_string(data)
	else:
		f.store_var(data, Full)
	f.close()

static func RemoveFile(at : String) -> int:
	var d : Directory = Directory.new()
	return d.remove(at)

static func MakeDir(p : String) -> void:
	var d : Directory = Directory.new()
	if !d.dir_exists(p):
		d.make_dir_recursive(p)


# ---------------- Call at start ----------------
static func BuildStaticVars_Files() -> void:
	pass



static func ParseSimpleString(s : String, color_as_rect : bool = false):
	var splits : Array = s.split_floats(",",false)
	match splits.size():
		0: return null
		1: return splits[0]
		2: return Vector2(splits[0], splits[1])
		3: return Vector3(splits[0], splits[1], splits[2])
		4:
			if color_as_rect: return Rect2(splits[0], splits[1], splits[2], splits[3])
			else: return Color(splits[0], splits[1], splits[2], splits[3])
		_: return null

static func ParseSimpleStringTo(s : String, type : int = NUMPER_TYPES.NUMPER):
	s = s.dedent().replace("(", "").replace(")", "")
	var splits : Array = s.split_floats(",",false)
	match type:
		NUMPER_TYPES.NUMPER:
			if splits: return splits[0]
			else: return 0
		NUMPER_TYPES.VECTOR2:
			if splits.size() == 1: return Vector2.RIGHT * splits[0]
			elif splits.size() >= 2: return Vector2(splits[0], splits[1])
			return Vector2.ONE
		NUMPER_TYPES.VECTOR3:
			if splits.size() == 1: return Vector3.UP * splits[0]
			elif splits.size() == 2: return Vector3(splits[0], splits[1], 0.0)
			elif splits.size() >= 3: return Vector3(splits[0], splits[1], splits[2])
			return Vector3.ONE
		NUMPER_TYPES.COLOR_NA:
			if splits.size() == 1: return Color().from_hsv(0.0, 0.0, splits[0], 1.0)
			elif splits.size() == 2: return Color().from_hsv(splits[0], splits[1], 0.0, 1.0)
			elif splits.size() >= 3: return Color(splits[0], splits[1], splits[2])
			return Color()
		NUMPER_TYPES.RECT2:
			if splits.size() == 1: return Rect2(Vector2.ZERO, Vector2.ONE * splits[0])
			elif splits.size() == 2: return Rect2(0.0, 0.0, splits[0], splits[1])
			elif splits.size() == 3: return Rect2(splits[0], splits[1], splits[2], splits[2])
			elif splits.size() >= 4: return Rect2(splits[0], splits[1], splits[2], splits[3])
			return Rect2()
		NUMPER_TYPES.COLOR:
			if splits.size() == 1: return Color().from_hsv(0.0, 0.0, splits[0], 1.0)
			elif splits.size() == 2: return Color().from_hsv(splits[0], splits[1], 0.0, 1.0)
			elif splits.size() == 3: return Color(splits[0], splits[1], splits[2])
			elif splits.size() >= 4: return Color(splits[0], splits[1], splits[2], splits[3])
			return Color()
		_:
			Exception.Threw("type", ERR_INVALID_PARAMETER)
			return null

static func ParseSimpleStringAny(s : String, flags : int = NUMPER_FLAGS.NUMPER):
	s = s.dedent().replace("(", "").replace(")", "")
	var splits : Array = s.split_floats(",",false)
	
	if flags & NUMPER_FLAGS.NUMPER:
		flags ^= NUMPER_FLAGS.NUMPER
		if flags:
			if splits.size() == 1: return splits[0]
		else:
			if splits: return splits[0]
			return 0
	
	if flags & NUMPER_FLAGS.VECTOR2:
		flags ^= NUMPER_FLAGS.VECTOR2
		if flags:
			if splits.size() == 2: return Vector2(splits[0], splits[1])
		else:
			if splits.size() == 1: return Vector2.RIGHT * splits[0]
			elif splits.size() >= 2: return Vector2(splits[0], splits[1])
			return Vector2.ONE
	
	if flags & NUMPER_FLAGS.VECTOR3:
		flags ^= NUMPER_FLAGS.VECTOR3
		if flags:
			if splits.size() == 3: return Vector3(splits[0], splits[1], splits[2])
		else:
			if splits.size() == 1: return Vector3.UP * splits[0]
			elif splits.size() == 2: return Vector3(splits[0], splits[1], 0.0)
			elif splits.size() >= 3: return Vector3(splits[0], splits[1], splits[2])
			return Vector3.ONE
		return Vector3.ONE
	
	if flags & NUMPER_FLAGS.RECT2:
		flags ^= NUMPER_FLAGS.RECT2
		if flags:
			if splits.size() >= 3: return Color(splits[0], splits[1], splits[2])
		else:
			if splits.size() == 1: return Color().from_hsv(0.0, 0.0, splits[0], 1.0)
			elif splits.size() == 2: return Color().from_hsv(splits[0], splits[1], 0.0, 1.0)
			elif splits.size() >= 3: return Color(splits[0], splits[1], splits[2])
			return Rect2()
	
	if flags & NUMPER_FLAGS.COLOR:
		flags ^= NUMPER_FLAGS.COLOR
		if flags:
			if splits.size() == 4: return Rect2(splits[0], splits[1], splits[2], splits[3])
		else:
			if splits.size() == 1: return Rect2(Vector2.ZERO, Vector2.ONE * splits[0])
			elif splits.size() == 2: return Rect2(0.0, 0.0, splits[0], splits[1])
			elif splits.size() == 3: return Rect2(splits[0], splits[1], splits[2], splits[2])
			elif splits.size() >= 4: return Rect2(splits[0], splits[1], splits[2], splits[3])
			return Color()
	
	if flags & NUMPER_FLAGS.COLOR_NA:
		flags ^= NUMPER_FLAGS.COLOR_NA
		if splits.size() == 1: return Color().from_hsv(0.0, 0.0, splits[0], 1.0)
		elif splits.size() == 2: return Color().from_hsv(splits[0], splits[1], 0.0, 1.0)
		elif splits.size() == 3: return Color(splits[0], splits[1], splits[2])
		elif splits.size() >= 4: return Color(splits[0], splits[1], splits[2], splits[3])
		return Color()
	
	Exception.Threw("type", ERR_INVALID_PARAMETER)
	return null

static func CleanPath(t : String) -> String:
	return t.replace("\\", "/").replace("//", "/")
static func SimpfyPath(t : String) -> String:
	return t.replace("\\", "/").replace("://","&css").replace("//", "/").replace("&css","://")

static func Parse(t : String, c : String, from : int = 0, to : int = 0) -> PoolIntArray:
	if to < 1: to = t.length()
	if from >= to:
		push_error( "'from' can't be bigger then 'to'" )
		return PoolIntArray([])
	if from < 0:
		push_error( "'from' can't be negtive" )
		return PoolIntArray([])
	
	var offset : int = from
	var text : String = t.substr(from, to - from)
	var Indexes : PoolIntArray = PoolIntArray()
	
	while true:
		var d : int = text.right(offset).find(c)
		if d < 0: return Indexes
		Indexes.append(offset + d)
		offset += d + 1
	return Indexes

static func ClampV2(r : Rect2, v : Vector2) -> Vector2: return Vector2(clamp(v.x, r.position.x, r.end.x), clamp(v.y, r.position.y, r.end.y))
static func ClampV3(r : AABB, v : Vector3) -> Vector3: return Vector3(clamp(v.x, r.position.x, r.end.x), clamp(v.y, r.position.y, r.end.y), clamp(v.z, r.position.z, r.end.z))

static func ImageTexture(b : Image, flags : int = 1) -> ImageTexture:
	var c : ImageTexture = ImageTexture.new()
	c.create_from_image(b, flags)
	return c

static func Private() -> bool:
	var a : Array = get_stack()
	return a.size() < 3 || a[2].source == a[1].source

static func SearchFolder(path : String, extansion := "json", deep := true) -> Array:
	var results : Array
	var dir = Directory.new()
	var folders : Array = []
	extansion = extansion.lstrip(". \n\t")
	
	if dir.open(path) == OK:
		dir.list_dir_begin()
		var file_name : String = dir.get_next()
#		while file_name:
#			if !extansion and !file_name in [".", ".."] and dir.current_is_dir():
#				results.append(SimpfyPath(path + "\\" + file_name))
#
#			elif dir.current_is_dir() and deep and !file_name in [".", ".."]:
#				folders.append(path + "\\" + file_name)
#
#			elif !dir.current_is_dir() and ![".", ".."].has(file_name) and extansion:
#				if file_name.get_extension() == extansion:
#
#					results.append(SimpfyPath(path + "\\" + file_name))
#
#			file_name = dir.get_next()
		if extansion:
			while file_name:
				if dir.current_is_dir() and deep and !file_name in [".", ".."]:
					folders.append(path + "\\" + file_name)
				elif !dir.current_is_dir() && file_name.get_extension() == extansion:
					results.append(SimpfyPath(path + "\\" + file_name))
				
				file_name = dir.get_next()
		else:
			while file_name:
				if dir.current_is_dir() and deep and !file_name in [".", ".."]:
					folders.append(path + "\\" + file_name)
				elif dir.current_is_dir() && !file_name in [".", ".."]:
					results.append(SimpfyPath(path + "\\" + file_name))
				
				file_name = dir.get_next()
	else:
		push_error("No folder at" + path)
		return []

	if deep:
		for i in folders:
			var scane : Array = SearchFolder(i, extansion, true)
			for j in scane.size():
				results.append(scane[j])

	return results

static func RemapDic2Str(dic : Dictionary, map : String = "{0}={1}") -> String:
	var str_p : String
	for x in dic:
		str_p += map.format([x, dic[x]]) + ","
	return str_p.rstrip(",")

static func RemapDic2Str2(dic : Dictionary, map : String = "{0}={1}", sep : String = ",") -> String:
	var str_p : String
	for x in dic:
		str_p += map.format([x, dic[x]]) + sep
	return str_p.rstrip(sep)

static func RemapArr2Str(arr : Array, map : String = "{1}-{0}") -> String:
	var str_p : String
	for x in arr.size():
		str_p += map.format([arr[x], x]) + ","
	return str_p.rstrip(",")

static func BuildObject(obj : Object, data : Dictionary) -> Object:
	for x in data:
		if x in obj:
			obj.set(x, data[x])
	return obj

static func BuildObject_Deep(obj : Object, data : Dictionary) -> Object: # Cost more
	for x in data:
		if x in obj || obj.get_indexed(x) != null:
			obj.set_indexed(x, data[x])
	return obj

static func Bytes2Ints(b : PoolByteArray) -> PoolIntArray:
	var s : PoolIntArray
	for x in range(0, (b.size() / 8) * 8, 8):
		s.append(b[x] + (b[x + 1] << 8) + (b[x + 2] << 16) + (b[x + 3] << 24) + (b[x + 4] << 32) + (b[x + 5] << 40) + (b[x + 6] << 48) + (b[x + 7] << 56))
	return s


static func TypeName(i) -> String: return TypeofName(typeof(i))

static func TypeofName(id : int) -> String:
	if abs(id) < TYPE_MAX: return TYPEOF_NAMES[abs(id)]  
	return "unknown"

static func Merges(arr : Array) -> Dictionary:
	var data : Dictionary
	for x in arr:
		for y in x:
			data[y] = x[y]
	return data

static func Merge(a : Dictionary, b : Dictionary, o :bool = false) -> Dictionary:
	if o:
		for x in b:
			a[x] = b[x]
	else:
		for x in b:
			a[x] = a.get(x, b[x])
	return a

static func ApplyOwner(node : Node, p_owner : Node) -> void:
	var nodes : Array = [node]
	
	while nodes:
		var n : Node = nodes.pop_back()
		if n != node and n.owner != node: n.owner = node
		nodes.append_array(n.get_children())

static func Bytes2ReadbleString(bytes : PoolByteArray) -> String:
	bytes.resize(ceil(bytes.size() / 3.0) * 3)
	bytes = PoolByteArray([bytes.size() >> 16, (bytes.size() >> 8) & 0xff, bytes.size() & 0xff]) + bytes
	var final : String
	for x in range(0, bytes.size(), 3):
		var v : int = bytes[x] + (bytes[x + 1] << 8) + (bytes[x + 2] << 16)
		final += BYTE2READBLE[v >> 18]
		final += BYTE2READBLE[(v >> 12) & 0x3f]
		final += BYTE2READBLE[(v >> 6) & 0x3f]
		final += BYTE2READBLE[v & 0x3f]
	return final

static func ReadbleString2Byes(s : String) -> PoolByteArray:
	if s.length() % 4:
		push_error("Invalid string!")
		return PoolByteArray([])
	var keys : Dictionary
	for x in BYTE2READBLE.length():
		keys[BYTE2READBLE[x]] = x
	
	var bytes : PoolByteArray
	for x in range(0, s.length(),4):
		var v : int = keys[s[x + 3]] + (keys[s[x + 2]] << 6) + (keys[s[x + 1]] << 12) + (keys[s[x]] << 18)
#		bytes.append_array([v>>16,(v>>8)&0xff,v&0xff])
		bytes.append_array([v&0xff,(v>>8)&0xff, v>>16])
	bytes.remove(0)
	bytes.remove(0)
	bytes.remove(0)
	return bytes


static func PackNode(n : Node) -> PackedScene:
	var p : PackedScene = PackedScene.new()
	var i : int = p.pack(n)
	if i: push_error("Error while packing node: %s" % [Exception.ERRORS_IDS[i]])
	return p

static func ReplaceAll(s : String, rep : Dictionary) -> String:
	for x in rep: s = s.replace(str(x), rep[x])
	return s

static func ReplacenAll(s : String, rep : Dictionary) -> String:
	for x in rep: s = s.replacen(str(x), rep[x])
	return s


static func MapLine(from : Vector2, to : Vector2) -> PoolVector2Array:
	from = from.round()
	to = to.round()
	if from == to: return PoolVector2Array([from, to])
	
	var point : Vector2 = from
	var points : PoolVector2Array = [from]
	
	while point != to:
		point += point.direction_to(to).round()
		points.append(point)
	
	return points


static func Restart(tree : SceneTree, args : Array = []) -> void:
	var p := OS.get_cmdline_args()
	var RunArgs : Dictionary
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
	var r : int
	if "runnumi" in RunArgs:
		r= int(RunArgs.runnumi)
		if r >= MAX_RERUN:
			OS.alert("Max reruns hit")
			return
	OS.execute(OS.get_executable_path(), args + ["--runnumi=%s" % [r + 1]], false)
	tree.quit()

static func CleanRunArg(s : String) -> String: return s.lstrip("-")
static func AorAN(s : String) -> String:
	if s: return "an" if s[0] in ["a", "e", "o", "u"] else "a"
	else: return "a"
