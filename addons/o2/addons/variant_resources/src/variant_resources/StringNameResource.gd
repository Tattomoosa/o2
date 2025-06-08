@tool
@icon("../../assets/icons/StringName.svg")
class_name StringNameResource
extends VariantResource

@export var value : StringName:
	get: return _value
	set(v): _set_value(v)

func _init() -> void:
	_type = TYPE_STRING_NAME
	_value = &""

func get_type() -> Variant.Type:
	return TYPE_STRING_NAME