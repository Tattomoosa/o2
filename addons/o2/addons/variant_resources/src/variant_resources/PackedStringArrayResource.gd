@tool
@icon("../../assets/icons/PackedStringArray.svg")
class_name PackedStringArrayResource
extends VariantResource

@export var value : PackedStringArray:
	get: return _value
	set(v): _set_value(v)

func _init() -> void:
	_type = TYPE_PACKED_STRING_ARRAY
	_value = PackedStringArray([])