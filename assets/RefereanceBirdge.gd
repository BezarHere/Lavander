extends Node

var Classes : Dictionary = {
	
}

var Scenes : Dictionary = {
	entity_hud = load("res://assets/ui/modules/EntityHUD.tscn")
}


var StaticVars : Dictionary

func InstanceScene(id : String) -> Object: return Scenes[id].instance()

func CheckProjectileHit(p : Projectile, b : Entity) -> void:
	if !b: return
	if b.Team != p.Team:
		b.Hurt({amount = p.Damage_Amount})
		p.queue_free()

func OnDataLoaded() -> void:
	PickupPopup.DATA_INIT()




func SetStatic(id : String, value, overwrite : bool = false) -> bool:
	if !overwrite && id in StaticVars: return false
	StaticVars[id] = {value = value, stack = get_stack()}; return true

func SetStaticAll(dic : Dictionary, overwrite : bool = false) -> void:
	for x in dic: SetStatic(x, dic[x], overwrite)

func GetStatic(id : String, default = null): return StaticVars.get(id, {}).get("value", default)

func HasStatic(id : String) -> bool: return id in StaticVars

func RemoveStatic(id : String) -> void: StaticVars.erase(id)
