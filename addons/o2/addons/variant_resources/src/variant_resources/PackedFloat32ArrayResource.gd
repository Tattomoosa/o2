@tool
@icon("../../assets/icons/PackedFloat32Array.svg")
class_name PackedFloat32ArrayResource
extends VariantResource

@export var value : PackedFloat32Array:
	get: return _value
	set(v): _set_value(v)

func _init() -> void:
	_type = TYPE_PACKED_FLOAT32_ARRAY
	_value = PackedFloat32Array([])

func get_type() -> Variant.Type:
	return TYPE_PACKED_FLOAT32_ARRAY