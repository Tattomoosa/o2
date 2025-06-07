@tool
@icon("../../assets/icons/PackedInt64Array.svg")
class_name PackedInt64ArrayResource
extends VariantResource

@export var value : PackedInt64Array:
	get: return _value
	set(v): _set_value(v)

func _init() -> void:
	_type = TYPE_PACKED_INT64_ARRAY
	_value = PackedInt64Array([])