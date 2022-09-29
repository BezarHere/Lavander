class_name EnemyGroup extends Struct

export var id : String
var amount : FloatingRange = FloatingRange.new(1, 4)
var chance : float
var effects : Array
var spawn_time : FloatingRange = FloatingRange.new(0, 1.5)


func New() -> Struct:
	var x : EnemyGroup = get_script().new()
	x.id = self.id
	x.amount.maximum = amount.maximum
	x.amount.minimum = amount.minimum
	x.chance = self.chance
	# Make effects copyble
	return x
