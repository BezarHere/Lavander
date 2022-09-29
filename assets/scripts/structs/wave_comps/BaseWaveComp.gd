class_name Base_WaveComp extends Struct

enum NOTIFICATION_TYPES {
	LOST
	COMPLETED
	KILLED_ENTITY
}

var Wave : Struct

var rewards : Cost = Cost.new()

func Notifiy(data : Dictionary) -> void:
	pass 
