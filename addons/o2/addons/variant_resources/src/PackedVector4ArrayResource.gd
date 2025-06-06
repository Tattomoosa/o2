@tool
@icon("../assets/icons/PackedVector4Array.svg")
class_name PackedVector4ArrayResource
extends VariantResource

@export var value : PackedVector4Array:
	get: return _value
	set(v): _set_value(v)

func _init() -> void:
	_type = TYPE_PACKED_VECTOR4_ARRAY
	_value = PackedVector4Array([])