tool
extends EditorPlugin

func _enter_tree() -> void:
	var hbc : HBoxContainer = get_editor_interface().get_script_editor().get_child(0).get_child(0)
	if hbc:
		for x in hbc.get_children():
			if x is HBoxContainer || x is MenuButton || x is ToolButton || x is VSeparator: continue
			x.visible = true


func ApplyOwner(node : Node, p_owner : Node) -> void:
	var nodes : Array = [node]
	
	while nodes:
		var n : Node = nodes.pop_back()
		if n != node and n.owner != node: n.owner = node
		nodes.append_array(n.get_children())
