class_name FU extends ReferenceStructure

static func WriteFile(path : String) -> File:
	var f : File = File.new()
	f.open(path, File.WRITE)
	if f.get_error(): push_error("Exception writing file - %s " % Exception.ERRORS_IDS[f.get_error()])
	return f

static func ReadFile(path : String) -> File:
	var f : File = File.new()
	f.open(path, File.READ)
	if f.get_error(): push_error("Exception reading file - %s " % Exception.ERRORS_IDS[f.get_error()])
	return f


static func SearchFolder(path : String, extansion := "json", deep := true) -> Array:
	var results : Array
	var dir = Directory.new()
	var folders : Array = []
	extansion = extansion.lstrip(". \n\t")
	
	if !dir.open(path):
		dir.list_dir_begin(true,true)
		var file_name : String = dir.get_next()
		if extansion:
			while file_name:
				if dir.current_is_dir():
					if deep: folders.append(path + "\\" + file_name)
				elif file_name.get_extension() == extansion:
					results.append(SimpfyPath(path + "\\" + file_name))
				file_name = dir.get_next()
		else:
			while file_name:
				if dir.current_is_dir():
					results.append(SimpfyPath(path + "\\" + file_name))
					if deep:
						folders.append(path + "\\" + file_name)
				file_name = dir.get_next()
		dir.list_dir_end()
	else:
		push_error("No folder at" + path)
		return []
	
	for i in folders:
		var scan : Array = SearchFolder(i, extansion, true)
		for j in scan:
			results.append(j)
	
	return results

static func SearchFolderForAll(path : String, deep := true) -> Array:
	var results : Array
	var dir = Directory.new()
	var folders : Array = []
	
	if !dir.open(path):
		dir.list_dir_begin(true,true)
		var file_name : String = dir.get_next()
		while file_name:
			results.append(SimpfyPath(path + "\\" + file_name))
			if deep && dir.current_is_dir():
				folders.append(path + "\\" + file_name)
			file_name = dir.get_next()
		dir.list_dir_end()
	else:
		push_error("No folder at" + path)
		return []
	
	for i in folders:
		var scan : Array = SearchFolderForAll(i, true)
		for j in scan:
			results.append(j)
	
	return results

static func FastSearchFolder(path : String, extansion := "json", deep := true) -> Array:
	var results : Array
	var dir = Directory.new()
	var folders : Array = []
	extansion = extansion.lstrip(". \n\t")
	
	if !dir.open(path):
		dir.list_dir_begin(true,true)
		var file_name : String = dir.get_next()
		if extansion:
			while file_name:
				if dir.current_is_dir():
					if deep: folders.append(path + "\\" + file_name)
				elif file_name.get_extension() == extansion:
					results.append(path + "\\" + file_name)
				file_name = dir.get_next()
		else:
			while file_name:
				if dir.current_is_dir():
					results.append(path + "\\" + file_name)
					if deep:
						folders.append(path + "\\" + file_name)
				file_name = dir.get_next()
		dir.list_dir_end()
	else:
		push_error("No folder at" + path)
		return []
	
	for i in folders:
		for j in SearchFolder(i, extansion, true):
			results.append(j)
	
	return results

static func SimpfyPath(t : String) -> String:
	return t.replace("\\", "/").replace("://","&css").replace("//", "/").replace("&css","://")

static func LoadTextrure(path : String, flags : int = 1) -> ImageTexture:
	var img : Image = Image.new()
	var tex : ImageTexture = ImageTexture.new()
	var err : int = img.load(path)
	if err:
		Exception.Threw("img.load(%s)", err)
		return null
	tex.storage = ImageTexture.STORAGE_COMPRESS_LOSSLESS
	tex.create_from_image(img, flags)
	return tex

static func DeleteFile(path : String) -> int:
	var dir : = Directory.new()
	return dir.remove(path)

static func GameFolder() -> String:
	var split : PoolStringArray = OS.get_executable_path().split("/")
	split.remove(split.size() - 1)
	return split.join("/")

static func DecumentsFolder() -> String:
	return OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)

static func Remove(at : String) -> int:
	var d : Directory = Directory.new()
	return d.remove(at)

static func RemoveDeep(at : String) -> int:
	var d : Directory = Directory.new()
	if d.open(at): return ERR_CANT_OPEN
	if d.current_is_dir(): for x in SearchFolderForAll(at): RemoveDeep(x)
	return d.remove(at)

static func MakeFolder(p : String) -> int:
	var d : Directory = Directory.new()
	return d.make_dir(p)

static func MakeFolderSafe(p : String) -> int:
	var d : Directory = Directory.new()
	return d.make_dir_recursive(p)


static func RemoveComments_OLd(text : String, commentPrefix := "//", PassCommentLines := true) -> String:
	var result := ""
	
	var InString := false
	var StringType := ""
	var SkipingLine : bool = false
	var IndexToSkip : int = 0
	
	
	for i in text.length():
		var s := text[i]
		if !s == commentPrefix[0]:
			result += s
			continue
		
		if IndexToSkip > 0:
			IndexToSkip -= 1
			continue
		
		var sc := text.substr(i, commentPrefix.length())
		
#		if SkipingLine and s != "\n":
#			pass
##			# if you make thing like '{"key": //temp comment//"value"}' it will be '{"key": "value"}'
##			if sc == commentPrefix:
##				SkipingLine = false
##				IndexToSkip = commentPrefix.length() - 1
##			continue
##
#		else:
		if PassCommentLines and SkipingLine and s == "\n":
			SkipingLine = false
			continue
		SkipingLine = false
		
		if (s == '"' or s == "'") and !SkipingLine:
			if StringType == s or StringType.empty():
				InString = !InString
				StringType = s
		
		if sc == commentPrefix and !InString:
			SkipingLine = true
		
		
		if !SkipingLine:
			result += s
	
	return result




#static func RemoveComments(text : String, commentPrefix := "//", PassCommentLines := true, d : bool = false) -> String:
#	var result := ""
#
#	var InString := false
#	var StringType := ""
#	var SkipingLine : bool = false
#
#	var i : int
#
#	var s : String
#	var sc : String
#
#	while i < text.length():
#		s = text[i]
#		sc = text.substr(i, commentPrefix.length())
#
#		if SkipingLine and s == "\n":
#			SkipingLine = false
#			if PassCommentLines:
#				continue
#
#		if (s == '"' or s == "'") and !SkipingLine:
#			var f : int = text.find(s, i + 1)
#			if f < 0:
#				result += text.substr(i)
#				break
#			if d:
#				printt(text.substr(i - 1, f - (i - 2)), f)
#			result += text.substr(i - 1, f - (i - 2))
#			i = f + 1
#			continue
#
#		if sc == commentPrefix and !InString:
#			SkipingLine = true
#
#
#		if !SkipingLine:
#			result += s
#		i += 1
#
#	return result


static func RemoveComments(text : String, commentPrefix := "//", PassCommentLines := true) -> String:
	var result := ""
	
	var InString := false
	var StringType := ""
	var SkipingLine : bool = false
	var IndexToSkip : int = 0
	
# warning-ignore:unused_variable
	var lines : int
	
	for i in text.length():
		var s := text[i]
		if s == "\n":
			lines+= 1
		var sc := text.substr(i, commentPrefix.length())
		
		if IndexToSkip > 0:
			IndexToSkip -= 1
			continue
		
#		if SkipingLine and s != "\n":
		if !(SkipingLine and s != "\n"):
#
#			# if you make thing like '{"key": //temp comment//"value"}' it will be '{"key": "value"}'
#			if sc == commentPrefix:
#				SkipingLine = false
#				IndexToSkip = commentPrefix.length() - 1
#			continue
#
#		else:
			if PassCommentLines and SkipingLine and s == "\n":
				SkipingLine = false
				continue
			SkipingLine = false
		
		if (s == '"' or s == "'") and !SkipingLine:
			if StringType == s or StringType.empty():
				InString = !InString
				StringType = s
		
		if sc == commentPrefix and !InString:
			SkipingLine = true
		
		
		if !SkipingLine:
			result += s
	
	return result

static func Cut(s : String, from : int, to : int) -> String: return s.left(from) + s.right(to)

static func SaveNode(n : Node, to : String) -> void:
	var p : PackedScene = PackedScene.new()
	p.pack(n)
	p.take_over_path(to)
	ResourceSaver.save(to, p)

static func CatorgraizedFilesSearch(path : String, exts : Array = [], deep : bool = false) -> Dictionary:
	if exts:
		var r := {}
		for x in exts:
			r[x] = SearchFolder(path, x, deep)
		return r
	else:
		var r := {}
		var all := SearchFolderForAll(path, deep)
		var ex : String
		for x in all:
			ex = x.get_extension().to_lower() # Windows doesn't have a case sensitive extensions
			if !ex: continue
			if !ex in r: r[ex] = []
			r[ex].append(x)
		return r
