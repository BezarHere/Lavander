class_name DirectoryWatcher
signal file_changed(path, change)

enum {
	FILECHANGE_DATA,
	FILECHANGE_REMOVED
}

var paths : Array
var streams : Dictionary

# -1 = Checks the whole file, >0 = checks the first bytes
var max_check_size : int = -1

func _notification(what: int) -> void:
	if what > 1002 && what < 1015 && what != 10012 && what != 1009: Update()

func Update() -> void:
	var f := File.new()
	var st := streams.duplicate()
	var pt := paths.duplicate()
	streams.clear()
	paths.clear()
	for x in pt.size():
		var p : String = pt[x]
		if !f.file_exists(p):
			emit_signal("file_changed", p, FILECHANGE_REMOVED)
			continue
		f.open(p, f.READ)
		var tr := f.get_buffer(f.get_len() if max_check_size < 1 else max_check_size)
		if p in st && tr != st[p]:
			emit_signal("file_changed", p, FILECHANGE_DATA)
		streams[p] = tr
		paths.append(p)

