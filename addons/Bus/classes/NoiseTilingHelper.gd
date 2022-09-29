class_name NoiseTilingHelper extends StructureBase
const Errors = {
	inv_data = "Invalid data",
	overflow = "Overflow",
	oot = "Out of time", 
	
	
	__u = "Unknown"
}

#var Marigins : Dictionary # { <offset, float> : <range, float> }
var Offsets : PoolRealArray
var Ranges : PoolRealArray

var Inputs : Array

var Result : String
var ResultMassege : String

func FillGaps() -> void:
	yield(Manger.get_tree(), "idle_frame")
	
	if Offsets.size() < Inputs.size():
		Throw(Errors.inv_data, "not enough Offsets.")
		return
	
#	if Ranges.size() < Inputs.size():
#		Throw(Errors.inv_data, "not enough Ranges.")
#		return
	
	if Inputs.size() < 3:
#		Throw(Errors.__u, "Low inputs", Repoter.Warn)
		return
	
	for i in range(1, Inputs.size() - 1):
		if i + 1 >= Inputs.size():
			break
		
		var o : float = Offsets[i]
		var r : float = Ranges[i]
		
		var next_o : float = Offsets[i + 1]
		var prev_o : float = Offsets[i - 1]
		var next_r : float = Ranges[i + 1]
#		var prev_r : float = Ranges[i - 1]
		
		if o < prev_o or o > next_o:
			Offsets.remove(i)
			Ranges.remove(i)
			Inputs.remove(i)
		
		o = (next_o + prev_o) / 2.0 # <----- normalzition to make the offset in the middle
		
		if o + r >= next_o - next_r:
			r = (o + r) - (next_o - next_r) 
		
		# the normalzition make this obslote
#		if o - r < prev_o + prev_r:
#			r = (next_o - next_r) - (o - r)
		
		Offsets[i] = o
		Ranges[i] = r

func ValueAt(k : float, default):
	for i in Inputs.size():
		if k < Offsets[i] + Ranges[i] and k > Offsets[i] - Ranges[i]:
			return Inputs[i]
	return default

func MaxValue() -> float:
	return Offsets[Offsets.size() - 1] + Ranges[Ranges.size() - 1]

func MinValue() -> float:
	return Offsets[0] - Ranges[0]

func Throw(i : String, ms : String) -> void:
	Result = i
	ResultMassege = ms
	push_error(Result + ResultMassege)

func GenrateWithTileset(t : TileSet, tiles : PoolStringArray) -> void:
	for i in tiles.size():
		Inputs.append(t.find_tile_by_name(tiles[i]))
