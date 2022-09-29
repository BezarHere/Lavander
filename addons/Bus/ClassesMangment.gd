class_name ClassesMangment 

enum FLAGS {
	STATIC = 1
	ABSTACT = 2
	TOOL = 4
	LIGHTWEIGHT = 8
	DATA_PACKEGE = 16
	MANIPULATOR = 32
}

static func ClassInfo(id : String, flags : int = 0, desc : String = "", path : String = "") -> ClassInfo:
	var b : ClassInfo = ClassInfo.new()
	b.id = id
	b.flags = flags
	b.desc = desc
	b.path = path
	return b

static func ListClasses() -> Array:
	return [
		ClassInfo("Data2Gdscript", FLAGS.MANIPULATOR),
		
		ClassInfo("DataTokenizer", FLAGS.DATA_PACKEGE | FLAGS.MANIPULATOR),
		ClassInfo("TokenBase"),
		ClassInfo("TokenArray"),
		ClassInfo("TokenBaseString"),
		ClassInfo("TokenDictionary"),
		ClassInfo("TokenFloat"),
		ClassInfo("TokenInt"),
		ClassInfo("TokenString"),
		
		ClassInfo("TokenString"),
		
		ClassInfo("Grid3D", FLAGS.DATA_PACKEGE),
		ClassInfo("Grid2D", FLAGS.DATA_PACKEGE),
		ClassInfo("Grid", FLAGS.DATA_PACKEGE),
		ClassInfo("BooleanGrid", FLAGS.DATA_PACKEGE),
		ClassInfo("IntegerGrid", FLAGS.DATA_PACKEGE),
		ClassInfo("ObjectsGrid", FLAGS.DATA_PACKEGE),
		ClassInfo("RealGrid", FLAGS.DATA_PACKEGE),
		ClassInfo("StringGrid", FLAGS.DATA_PACKEGE),
		
		ClassInfo("FloatingChance", FLAGS.LIGHTWEIGHT),
		ClassInfo("FloatingRange", FLAGS.LIGHTWEIGHT),
		ClassInfo("IntRange", FLAGS.LIGHTWEIGHT),
		ClassInfo("NumperRange", FLAGS.ABSTACT),
		ClassInfo("Ranges", FLAGS.STATIC),
		
		ClassInfo("CHANCE", FLAGS.LIGHTWEIGHT),
		ClassInfo("Math", FLAGS.STATIC),
		ClassInfo("Matric8x8",FLAGS.DATA_PACKEGE),
		ClassInfo("Matric64x64",FLAGS.DATA_PACKEGE),
		
		ClassInfo("HPileContainer", FLAGS.TOOL),
		ClassInfo("IDButton", FLAGS.TOOL),
		ClassInfo("IDTextureButton", FLAGS.TOOL),
		ClassInfo("PrecntegeContainer", FLAGS.TOOL),
		ClassInfo("SoundedSlider", FLAGS.TOOL),
		ClassInfo("StackContainer", FLAGS.TOOL),
		ClassInfo("UILib", FLAGS.TOOL | FLAGS.MANIPULATOR | FLAGS.STATIC),
		
		ClassInfo("AreaRange2D", FLAGS.TOOL),
		
		ClassInfo("Cache", FLAGS.LIGHTWEIGHT | FLAGS.DATA_PACKEGE),
		
		ClassInfo("ErrorsBuilder", FLAGS.MANIPULATOR),
		
		ClassInfo("Exception", FLAGS.STATIC),
		
		ClassInfo("ExtendedOS", FLAGS.STATIC | FLAGS.ABSTACT),
		ClassInfo("FilesLoader", FLAGS.MANIPULATOR),
		
		ClassInfo("ImgIncoder", FLAGS.DATA_PACKEGE),
		
		ClassInfo("IntMap", FLAGS.DATA_PACKEGE),
		ClassInfo("StringMap", FLAGS.DATA_PACKEGE),
		
		ClassInfo("MemoryTracker", FLAGS.LIGHTWEIGHT),
		ClassInfo("StopWatch", FLAGS.LIGHTWEIGHT),
		
		ClassInfo("NoiseMap", FLAGS.MANIPULATOR),
		ClassInfo("NoiseTilingHelper", FLAGS.MANIPULATOR),
		
		ClassInfo("ObjectStructure", FLAGS.ABSTACT | FLAGS.LIGHTWEIGHT),
		ClassInfo("ReferenceStructure", FLAGS.ABSTACT | FLAGS.LIGHTWEIGHT),
		ClassInfo("ResourceStructure", FLAGS.ABSTACT | FLAGS.LIGHTWEIGHT),
		
		ClassInfo("Point", FLAGS.LIGHTWEIGHT),
		
		ClassInfo("REF", FLAGS.LIGHTWEIGHT),
		ClassInfo("RefLinks", FLAGS.DATA_PACKEGE),
		
		ClassInfo("RefrenceHolder", FLAGS.DATA_PACKEGE),
		
		ClassInfo("RNG", FLAGS.LIGHTWEIGHT),
		
		ClassInfo("SoundStreamPlayer2D", FLAGS.TOOL),
		ClassInfo("SoundStreamPlayer", FLAGS.TOOL),
		
		ClassInfo("StructureBase", FLAGS.ABSTACT | FLAGS.LIGHTWEIGHT),
		
		ClassInfo("ValueCurve", FLAGS.TOOL),
		
		ClassInfo("JsonF", FLAGS.MANIPULATOR),
		
		
		ClassInfo("SU", FLAGS.MANIPULATOR | FLAGS.STATIC, "StaticUtility wich have some helper classes accounting file & directory mangment and basic value manipulator\nCan be great to cut coding time!"),
		ClassInfo("GU", FLAGS.MANIPULATOR | FLAGS.STATIC, "GraphicsUtility wich genraly used to convert and handle graphics data (e.g. Image, ImageTextrue, AnimatedSprites ...etc)"),
		ClassInfo("FU", FLAGS.MANIPULATOR | FLAGS.STATIC, "FilesUtility is a basic tool to make file/saves/mod loading mangment easier."),
	]
