@tool
@icon("../assets/icons/Vector4i.svg")
class_name Vector4iResource
extends VariantResource

@export var value : Vector4i:
	get: return _value
	set(v): _set_value(v)

func _init() -> void:
	_type = TYPE_VECTOR4I
	_value = Vector4i.ZERO