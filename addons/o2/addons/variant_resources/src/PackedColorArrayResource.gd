@tool
class_name PackedColorArrayResource
extends VariantResource

@export var value : PackedColorArray:
	get: return _value
	set(v): _set_value(v)

func _init() -> void:
	_type = TYPE_PACKED_COLOR_ARRAY
	_value = PackedColorArray([])