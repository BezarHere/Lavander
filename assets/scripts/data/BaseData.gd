class_name BaseData extends ResourceStructure

enum { # VALUE TYPES
	VT_NUM,
	VT_STRING,
	VT_DICTIONARY,
	VT_ARRAY,
	VT_BOOL
}
const VT_DEF = [
	0,"", {}, [], false
]
const VT_NAME = [
	"numper",
	"string",
	"object",
	"array",
	"bool"
]

var rng := RNG.new()

export var id : String

export var name : String
export var desc : String
export var hint : String

export var raw : Dictionary

export var path : String
export var mod : String

export var valid : bool

export var errors : Array
export var warnings : Array
export var masseges : Array

func Construct(data : Dictionary) -> void:
	raw = data.duplicate(true)
	raw.merge(Defaults())
	ItrateData(raw)
	Build(raw)
	FlushLog()

func Build(data : Dictionary) -> void:
	name = data.name
	desc = data.desc

func Defaults() -> Dictionary: return {
	name = "unknwon", desc = "unknown"
}

func ItrateData(data : Dictionary) -> void:
	for x in data: data[x] = MoldData(x, data[x])

func MoldData(id : String, value): return value

static func Merge(d1 : Dictionary, d2 : Dictionary) -> Dictionary: 
	var p := d1.duplicate(true); p.merge(d2); return p

func FlushLog() -> void:
	return

static func IsNum(i) -> bool: return i is float || i is int


static func SAFE(f : float) -> float: return f + 0.0001 if f >= 0 else f - 0.0001


