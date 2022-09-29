class_name Cost extends Struct

export var Photons : float
export var StarDust : float

# Xp gain on purchase!
export var Xp : float

func IsUseble() -> bool:
	return Game.Photons >= Photons && Game.StarDust >= StarDust

func Use() -> void:
	if Photons: Game.ChangePhotons(-Photons)
	if StarDust: Game.ChangePhotons(-StarDust)
	if Xp: Game.ChangeXp(Xp)

func UseAsReward() -> void:
	if Photons: Game.ChangePhotons(Photons)
	if StarDust: Game.ChangePhotons(StarDust)
	if Xp: Game.ChangeXp(Xp)
