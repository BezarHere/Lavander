class_name Exception

const ERRORS_IDS = [
	"", # OK
	"failed",
	
	"unavailable",
	"unconfigured",
	"unauthorized",
	"parameter range error", # 5
	
	"out of memory",
	"file not found",
	"file bad drive",
	"file bad path",
	"no premission to file", # 10
	
	"file in use",
	"cant open file",
	"cant write file",
	"cant read file",
	"unrecognized file", # 15
	
	"corrupted file",
	"file missing dependencies",
	"end of file",
	"cant open",
	"cant create", # 20
	
	"query error",
	"already in use",
	"locked",
	"timeout",
	"cant connect", # 25
	
	"cant resolve",
	"connection error",
	"cant acquire resource",
	"cant fork",
	"invalid data", # 30
	
	"invalid paramter",
	"already exists",
	"does not exist",
	"cant read from data base",
	"cant write to data base", # 35
	
	"compilation failed",
	"method not found",
	"link failed",
	"script failed",
	"cycle link", # 40,
	
	"invalid declaration",
	"duplicate symbol",
	"parse error",
	"busy",
	"skip", # 45
	
	"help",
	"bug",
	"printer on fire",
	
	# My designe ->
	
	"out of range",
	
	"is negitive", # 50
	"is zero",
	"is not positive",
	"is empty",
	"is oversized",
	"is insufficent", # 55
	"has an invalid type",
	"has an invalid type",
	"is an invalid id",
	"is an invalid property",
]

enum  {
	ERR_PARAMTER_OUT_OF_RANGE = ERR_PRINTER_ON_FIRE + 1
	ERR_PR_NEGITIVE, # Paramter Range
	ERR_PR_ZERO,
	ERR_PR_REQ_POSITIVE,
	ERR_EMPTY,
	ERR_OVERSIZE
	ERR_INSUFFICENT
	ERR_INVALID_TYPE
	ERR_INVALID_IND
	ERR_INVALID_PRO
}


static func OutOfRange(id : String = "Uknown") -> void: push_error("'%s' is out of range" % id)

static func NotImplemnted(id : String = "Uknown") -> void: push_error("'%s' Not implemnted" % id)

static func UnexpectedNull(id : String = "Uknown") -> void: push_error("'%s' Unexpected to be null" % id)
static func IsNull(value, id : String) -> bool:
	if value == null:
		UnexpectedNull(id)
		return true
	return false

static func UnexpectedNullOrFreedInstance(id : String = "Uknown") -> void: push_error("'%s' Unexpected to be null or freed" % id)
static func IsNullOrFreed(value : Object, id : String) -> bool:
	if !value || !is_instance_valid(value):
		UnexpectedNullOrFreedInstance(id)
		return true
	return false

static func Mismatch(id0 : String = "Uknown", id1 : String = "Unknown") -> void: push_error("\"%s\" & \"%s\" Are mismatched" % [id0, id1])
static func Match(id0 : String = "Uknown", id1 : String = "Unknown") -> void: push_error("\"%s\" & \"%s\" Are matched" % [id0, id1])

static func Inequal(id0 : String = "Uknown", id1 : String = "Unknown") -> void: push_error("\"%s\" & \"%s\" Are Inequal" % [id0, id1])
static func Equal(id0 : String = "Uknown", id1 : String = "Unknown") -> void: push_error("\"%s\" & \"%s\" Are equal" % [id0, id1])

static func InvalidMethodUse(mth : String, reason : String = "invaild use") -> void: push_error("\"%s()\" %s" % [mth, reason])

static func InvalidType(p : String, type0 : String, type1 : String) -> void: push_error("\"%s\" type is\"\" but the required type is \"%s\"" % [p,type0,type1])

static func Private(p : String, mth : bool = false) -> bool:
	var a : Array = get_stack()
	if a.size() < 3 || a[2].source == a[1].source: return true
	PrivateViolation(p,mth)
	return false

static func PrivateViolation(p : String, mth : bool = false) -> void: assert(false, "\"%s\" Is private %s" % [p, "function" if mth else "property"])
static func ReadOnlyViolation(p : String) -> void: push_error("\"%s\" Is read only" % [p])

static func StaticViolation(c_name : String) -> void: assert(false, "static class \"%s\" shouldn't be instanced" % [c_name])

static func Overflow(c_name : String) -> void: push_error("OverflowException: %s" % c_name)

static func Threw(id : String, type : int) -> void: push_error("'%s' %s" % [id, ERRORS_IDS[type]])
