@tool
@icon("../../assets/icons/PackedColorArray.svg")
class_name PackedColorArrayResource
extends VariantResource

@export var value : PackedColorArray:
	get: return _value
	set(v): _set_value(v)

func _init() -> void:
	_type = TYPE_PACKED_COLOR_ARRAY
	_value = PackedColorArray([])
	
func get_type() -> Variant.Type:
	return TYPE_PACKED_COLOR_ARRAY