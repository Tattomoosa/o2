@tool
@icon("../../assets/icons/Vector3.svg")
class_name Vector3Resource
extends VariantResource

@export var value : Vector3:
	get: return _value
	set(v): _set_value(v)

func _init() -> void:
	_type = TYPE_VECTOR3
	_value = Vector3.ZERO

func get_type() -> Variant.Type:
	return TYPE_VECTOR3