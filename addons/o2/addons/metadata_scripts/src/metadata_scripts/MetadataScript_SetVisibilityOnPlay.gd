@tool
class_name MetadataScript_SetVisibleOnPlay
extends MetadataScript

@export var visible := false

func _enter_tree() -> void:
	if !Engine.is_editor_hint():
		if "visible" in node:
			node.visible = visible

static func can_attach_to(p_node: Node) -> bool:
	return super(p_node) and "visible" in p_node