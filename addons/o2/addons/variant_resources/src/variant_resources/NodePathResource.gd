@tool
@icon("../../assets/icons/NodePath.svg")
class_name NodePathResource
extends VariantResource

@export var value : NodePath:
	get: return _value
	set(v): _set_value(v)

func _init() -> void:
	_type = TYPE_NODE_PATH
	_value = NodePath()
