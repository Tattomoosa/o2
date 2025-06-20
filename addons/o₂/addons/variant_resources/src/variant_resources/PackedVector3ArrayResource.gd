@tool
@icon("../../assets/icons/PackedVector3Array.svg")
class_name PackedVector3ArrayResource
extends VariantResource

@export var value : PackedVector3Array:
	get: return _value
	set(v): _set_value(v)

func _init() -> void:
	_type = TYPE_PACKED_VECTOR3_ARRAY
	_value = PackedVector3Array([])

func get_type() -> Variant.Type:
	return TYPE_PACKED_VECTOR3_ARRAY