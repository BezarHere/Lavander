extends Object
class_name StructureBase
var __QueuedForDeletion : bool = false

func QueueFree():
	__QueuedForDeletion = true
	call_deferred("free")

func Serlize(unbinds := [], b1 := false) -> Dictionary:
	var d : Dictionary = inst2dict(self)
	d.erase("@subpath")
	if b1:
		d.erase("@path")
	for i in unbinds:
		if !i is String:
			continue
		if d.has(i):
			d.erase(i)
	return d

func Unserlize(data : Dictionary) -> void:
	for i in data:
		if i in self:
			set(i, data[i])
