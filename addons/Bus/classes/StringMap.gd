extends ResourceStructure
class_name StringMap

var Map : Array
var Size : Vector2
var Length : int



func Create(n_Size : Vector2) -> void:
	Size = n_Size
	Map.clear()
	for x in Size.x:
		Map.append([])
		for y in Size.y:
			Map[x].append("")
		
	
	pass

func SetString(x : int, y : int, s : String) -> bool:
	if Map.size() <= x:
		Reporter.Log("IndexingRowOutRange_StringMap: Maxium row index %s, Indexing row %s" % [Map.size() - 1, x], Reporter.Err)
		return false
	
	if Map[x].size() <= y:
		Reporter.Report("IndexingPositionOutRange_StringMap: Maxium position index %s, Indexing position %s" % [Map.size() - 1, x], Reporter.Err)
		return false
	
	Length += s.length() - Map[x][y].length()
	Map[x][y] = s
	return true

func GetString(x : int, y : int) -> String:
	if Map.size() <= x:
		Reporter.Report( "IndexRowOutRange_StringMap: Maxium row index %s, Indexing row %s" % [Map.size() - 1, x], Reporter.Err)
		return ""
	
	if Map[x].size() <= y:
		Reporter.Report( "IndexPositionOutRange_StringMap: Maxium position index %s, Indexing position %s" % [Map.size() - 1, x], Reporter.Err)
		return ""
	
	return Map[x][y]

func GenrateIntMap() -> IntMap:
	var map := IntMap.new()
	map.Create(Size)
	
	for x in Size.x:
		for y in Size.y:
			map.SetInt(x, y, Map[x][y].length())
	
	return map

