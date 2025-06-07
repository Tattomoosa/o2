@tool
@icon("../../assets/icons/PackedInt32Array.svg")
class_name PackedInt32ArrayResource
extends VariantResource

@export var value : PackedInt32Array:
	get: return _value
	set(v): _set_value(v)

func _init() -> void:
	_type = TYPE_PACKED_INT32_ARRAY
	_value = PackedInt32Array([])