@tool
@icon("../assets/icons/bool.svg")
class_name BoolResource
extends VariantResource

## Boolean value
@export var value : bool:
	get: return _value
	set(v): _set_value(v)

func _init() -> void:
	_type = TYPE_BOOL
	_value = false
