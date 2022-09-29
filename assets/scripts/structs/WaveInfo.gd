class_name WaveInfo extends Struct

export var Tags : Array
export var Componets : Array
export var Enemies : Array

func NotifyComponets(data : Dictionary) -> void:
	for x in Componets:
		x.Notify(data)


