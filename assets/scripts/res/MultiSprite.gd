tool
class_name MultiSprite extends Sprite

export(int, 0, 1000) var index : int setget set_index
export(Array, Texture) var textures : Array setget set_textures

func set_textures(value : Array) -> void:
	textures = value; set_index(index)

func set_index(value : int) -> void:
	index = clamp(value, 0, textures.size() - 1); reload_texture()

func reload_texture() -> void:
	texture = get_current_texture()
	update()

func get_current_texture() -> Texture: return null if textures.empty() else textures[index]

