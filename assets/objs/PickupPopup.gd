class_name PickupPopup extends Sprite

static func DATA_INIT() -> void:
	ReferenceBirdge.SetStaticAll({
		"PickupPopup.ammo" : DataManger.GetGraphicsSafe("icons.pickup.ammo"),
		"PickupPopup.heal" : DataManger.GetGraphicsSafe("icons.pickup.heal"),
		"PickupPopup.power" : DataManger.GetGraphicsSafe("icons.pickup.power"),
	})

export var Type : int

func _ready() -> void:
	texture
