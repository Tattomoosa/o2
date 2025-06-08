@tool
@icon("../../assets/icons/Transform2D.svg")
class_name Transform2DResource
extends VariantResource

@export var value : Transform2D:
	get: return _value
	set(v): _set_value(v)

func _init() -> void:
	_type = TYPE_TRANSFORM2D
	_value = Transform2D()

func get_type() -> Variant.Type:
	return TYPE_TRANSFORM2D