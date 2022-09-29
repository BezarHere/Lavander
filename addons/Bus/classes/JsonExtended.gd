class_name JsonF extends JSON

enum {
	STRING_S
	STRING_D
}

var Itrations : int

func Parse(text : String) -> void:
	var InString : int
	var Index : int
	var TLength : int = text.length()
	var OpenedMain : bool
	var SubArrays : int
	var SubObjs : int
	var Saperated : bool
	
	while Index < TLength:
		
		match text[Index]:
			"{":
				if OpenedMain: SubObjs += 1
				else: OpenedMain = true
			"}":
				if SubObjs: SubObjs -= 1
				else:
					OpenedMain = false
					Index = TLength
			"[":
				SubArrays += 1
			"]":
				SubArrays -= 1
			"\"", "'":
				var f : int = text.find(text[Index], Index)
				if f >= 0: Index = f
				else: Index = TLength # No end to the string
			"\t","\n"," ":
				var removes : int
				while text[Index] in ["\t","\n"," "]:
					removes += 1
					Index += 1
				text = text.left(Index - (removes - 1)) + text.right(Index + removes)
				Index -= removes
				TLength -= removes
		
		Index += 1
	
	print(text)


