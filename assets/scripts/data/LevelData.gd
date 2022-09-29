class_name LevelData extends BaseData

enum  {
	TYPE_LEVEL
	TYPE_BONUS_LVL
	TYPE_BOSS_LVL
}

export var Hidden : bool = false

export var Type : int

var Rq : LevelRq = LevelRq.new()

export var ColorSpectrum : Gradient = null
export var Position : Vector2
export var ConnectedTo : Array

export var Waves : Array

export var Graphics : Dictionary

export var VisualTyp : int

export var Tags : Array

func Build(data : Dictionary) -> void:
	.Build(data)
	var trace : String = "in Stage(%s) at path \"%s\"" % [id, path]
	if "hidden" in data: Hidden = ParseUtility.CheckForBool("hidden", data, trace, {default = true})
	
#	ColorSpectrum = ParseUtility.CheckForGradient("colors", data, trace, {default = Gradient.new()})
	ConnectedTo = ParseUtility.CheckForArray("connected_to", data, trace, {default = []})
	for x in ConnectedTo.size():
		if !ConnectedTo[x] is String:
			Log.Error("Field \"connected_to.%s\" should be a level id (string)" % x)
			ConnectedTo.remove(x)
	
	Position = ParseUtility.CheckForVector2("position", data, trace, {default = Position})
	
	if "tags" in data:
		var tgs : = ParseUtility.CheckForArray("tags", data, trace, {default = []})
		for x in tgs.size():
			if !tgs[x] is String:
				Log.Error("Field \"tags.%s\" should be a string" % x)
				continue
			Tags.append(tgs[x])
	
	var g_data : Dictionary = ParseUtility.CheckForDictionary("graphics", data, trace, {trace_id = "graphics", default = {}})
	
	for x in g_data:
		Graphics[x] = DataManger.LoadGraphics(g_data[x], {id = id, subid = x, mod = mod, path = path})
	
	var req : Dictionary
	
	if "req" in data:
		req = ParseUtility.CheckForDictionary("req", data, trace, {default = {}})
		var rq_cost : Dictionary = ParseUtility.CheckForDictionary("cost", req, trace, {default = {}, trace_id = "req.cost"})
		if "photons" in rq_cost: Rq.UnlockCost.Photons = ParseUtility.CheckForNumperPositive("photons", rq_cost, trace, {default = 0, trace_id = "req.cost.photons"})
		if "stardust" in rq_cost: Rq.UnlockCost.StarDust = ParseUtility.CheckForNumperPositive("stardust", rq_cost, trace, {default = 0, trace_id = "req.cost.stardust"})
		if "xp" in rq_cost: Rq.UnlockCost.Xp = ParseUtility.CheckForNumperPositive("xp", rq_cost, trace, {default = 0, trace_id = "req.cost.xp"})
		Rq.Prerequsts = ParseUtility.CheckForArray("prerequsts", req, trace, {deafult = [], trace_id = "req.prerequsts"})
		
		for x in Rq.Prerequsts.size():
			if !Rq.Prerequsts[x] is String:
				Log.Error("Field \"req.prerequsts.%s\" should be a stage id (string)" % x)
				Rq.Prerequsts.remove(x)
	
	var waves_data : Array = ParseUtility.CheckForArray("waves", data, trace, {default = []})
	
	for x in waves_data.size():
		if !waves_data[x] is Dictionary:
			Log.Error("Field \"waves.%s\" should be a wave (object)" % x)
			continue
		
		var wave : = WaveInfo.new()
		
		var wave_tags : = ParseUtility.CheckForArray("tags", waves_data[x], trace, {default = [], trace_id = "waves.%s.tags" % x})
		for i in wave_tags.size():
			if !wave_tags[i] is String:
				Log.Error("Field \"waves.%s.tags.%s\" should be a string" % [x,i])
				continue
			wave.Tags.append(wave_tags[i])
		
		var enemies : Array = ParseUtility.CheckForArray("enemies", waves_data[x], trace, {default = [], trace_id = "waves.%s.enemies" % x})
		for i in enemies.size():
			if !enemies[i] is Dictionary:
				Log.Error("Field \"waves.%s.enemies.%s\" should be an object" % [x,i])
				continue
			var e := EnemyGroup.new()
			e.id = ParseUtility.CheckForString("id", enemies[i], trace, {default = [], trace_id = "waves.%s.enemies.%s.id" % [x,i]})
			
			if !"amount" in enemies[i] && !"amount_max" in enemies[i] && !"amount_min" in enemies[i]:
				Log.Error("No field(s) in \"waves.%s.enemies.%s\" that indecate enemies amount (use <amount:int> or <amount_min:numper> & <amount_max:numper>)" % [x,i])
			elif "amount_min" in enemies[i] || "amount_max" in enemies[i]:
				e.amount.minimum = ParseUtility.CheckForNumperPositive("amount_min", enemies[i], trace, {default = [], trace_id = "waves.%s.enemies.%s.amount_min" % [x,i]})
				e.amount.maximum = ParseUtility.CheckForNumperPositiveNonzeroI("amount_max", enemies[i], trace, {default = [], trace_id = "waves.%s.enemies.%s.amount_max" % [x,i]})
			else:
				e.amount.settel_at(ParseUtility.CheckForNumperPositiveNonzeroI("amount", enemies[i], trace, {default = [], trace_id = "waves.%s.enemies.%s.amount" % [x,i]}))
			
			if "chance" in enemies[i]:
				e.chance = ParseUtility.CheckForNumperPositive("chance", enemies[i], trace, {default = [], trace_id = "waves.%s.enemies.%s.chance" % [x,i]})
			
			if "effects" in enemies[i]:
				pass # Make effects for EnemyGroup and expose it for modders!
			
			wave.Enemies.append(e)
		
		var comps : Array = ParseUtility.CheckForArray("comps", waves_data[x], trace, {default = [], trace_id = "waves.%s.comps" % x})
		
		for i in comps.size():
			if !comps[i] is Dictionary:
				Log.Error("Field \"waves.%s.comps.%s\" should be an object" % [x,i])
				continue
			
			var com : Base_WaveComp = DataManger.GetWaveCompScript(ParseUtility.CheckForString(
				"type" , comps[i], trace, {default = "", trace_id = "waves.%s.comps.%s.type" % [x,i], inputs = DataManger.WAVECOMPS_SCRIPTS.keys() }
			)).new()
			
			com.Wave = wave
			
			if com is Reward_WaveComp: com.rewards = ParseConstruct.ConstructCost(
				"reward", comps[i], trace, {default = Cost.new(), trace_id = "waves.%s.comps.%s.reward" % [x,i]}
			)
			
			
			
			wave.Componets.append(com)
		
		Waves.append(wave)
		
		
	
