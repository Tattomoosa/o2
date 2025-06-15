@tool
@icon("../../assets/icons/String.svg")
class_name StringResource
extends VariantResource

@export var value : String:
	get: return _value
	set(v): _set_value(v)

func _init() -> void:
	_type = TYPE_STRING
	_value = ""

func get_type() -> Variant.Type:
	return TYPE_STRING