@tool
@icon("../../assets/icons/PackedVector2Array.svg")
class_name PackedVector2ArrayResource
extends VariantResource

@export var value : PackedVector2Array:
	get: return _value
	set(v): _set_value(v)

func _init() -> void:
	_type = TYPE_PACKED_VECTOR2_ARRAY
	_value = PackedVector2Array([])