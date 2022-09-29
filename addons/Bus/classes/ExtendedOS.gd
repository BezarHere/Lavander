class_name OSTools extends ObjectStructure

static func UnixDateTime() -> float: return OS.get_unix_time() + ((OS.get_ticks_msec() % 1000) / 1000.0)
static func UnixDateTimeUSec() -> float: return OS.get_unix_time() + ((OS.get_ticks_usec() % 1000000) / 1000000.0)

static func UserFolder() -> String:
	var s : PoolStringArray = OS.get_user_data_dir().split("/")
	return PoolStringArray([s[0],s[1],s[2]]).join("/")

static func Open(path : String) -> int:
	path = path.replace("/", "\\")
	var i := OS.shell_open("\"%s\"" % path)
	if i: push_error("Error while opening \"%s\" as %s" % [path, Exception.ERRORS_IDS[i]])
	return i
