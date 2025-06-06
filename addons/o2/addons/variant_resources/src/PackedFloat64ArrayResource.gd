@tool
class_name PackedFloat64ArrayResource
extends VariantResource

@export var value : PackedFloat64Array:
	get: return _value
	set(v): _set_value(v)

func _init() -> void:
	_type = TYPE_PACKED_FLOAT64_ARRAY
	_value = PackedFloat64Array([])