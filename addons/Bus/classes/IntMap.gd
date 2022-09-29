extends ResourceStructure
class_name IntMap

var Map : Array
var Size : Vector2
var Length : int
var AbsLength : int

func Create(n_Size : Vector2) -> void:
	Size = n_Size
	Map.clear()
	for x in Size.x:
		Map.append([])
		for y in Size.y:
			Map[x].append(0)


	pass

func SetInt(x : int, y : int, s : int) -> bool:
	if Map.size() <= x:
		Reporter.Report("IndexingRowOutRange_IntMap: Maxium row index %s, Indexing row %s" % [Map.size() - 1, x], Reporter.RepTypes.Err)
		return false

	if Map[x].size() <= y:
		Reporter.Report("IndexingPositionOutRange_IntMap: Maxium position index %s, Indexing position %s" % [Map.size() - 1, x], Reporter.RepTypes.Err)
		return false

	Length += s - Map[x][y]
	AbsLength += abs(s) - abs(Map[x][y])
	Map[x][y] = s
	return true

func GetInt(x : int, y : int) -> int:
	if Map.size() <= x:
		Reporter.Report("IndexRowOutRange_IntMap: Maxium row index %s, Indexing row %s" % [Map.size() - 1, x], Reporter.RepTypes.Err)
		return 0

	if Map[x].size() <= y:
		Reporter.Report("IndexPositionOutRange_IntMap: Maxium position index %s, Indexing position %s" % [Map.size() - 1, x], Reporter.RepTypes.Err)
		return 0

	return Map[x][y]

