@tool
class_name MetadataScript_SetVisibilityOnPlay
extends MetadataScript

@export var set_visibility_to := false

func _enter_tree() -> void:
	if !Engine.is_editor_hint():
		if "visible" in node:
			node.visible = set_visibility_to

static func can_attach_to(p_node: Node) -> bool:
	return super(p_node) and "visible" in p_node