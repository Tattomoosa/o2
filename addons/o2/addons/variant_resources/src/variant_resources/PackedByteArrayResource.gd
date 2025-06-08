@tool
@icon("../../assets/icons/PackedByteArray.svg")
class_name PackedByteArrayResource
extends VariantResource

@export var value : PackedByteArray:
	get: return _value
	set(v): _set_value(v)

func _init() -> void:
	_type = TYPE_PACKED_BYTE_ARRAY
	_value = PackedByteArray([])

func get_type() -> Variant.Type:
	return TYPE_PACKED_BYTE_ARRAY
