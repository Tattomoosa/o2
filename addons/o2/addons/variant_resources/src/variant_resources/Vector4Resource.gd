@tool
@icon("../../assets/icons/Vector4.svg")
class_name Vector4Resource
extends VariantResource

@export var value : Vector4:
	get: return _value
	set(v): _set_value(v)

func _init() -> void:
	_type = TYPE_VECTOR4
	_value = Vector4.ZERO

func get_type() -> Variant.Type:
	return TYPE_VECTOR4