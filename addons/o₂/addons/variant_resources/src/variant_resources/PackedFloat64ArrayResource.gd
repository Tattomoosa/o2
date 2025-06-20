@tool
@icon("../../assets/icons/PackedFloat64Array.svg")
class_name PackedFloat64ArrayResource
extends VariantResource

@export var value : PackedFloat64Array:
	get: return _value
	set(v): _set_value(v)

func _init() -> void:
	_type = TYPE_PACKED_FLOAT64_ARRAY
	_value = PackedFloat64Array([])

func get_type() -> Variant.Type:
	return TYPE_PACKED_FLOAT64_ARRAY