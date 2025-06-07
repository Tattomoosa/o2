@tool
@icon("../../assets/icons/int.svg")
class_name IntResource
extends VariantResource

## Int value
@export var value : int:
	get: return _value
	set(v): _set_value(v)

func _init() -> void:
	_type = TYPE_INT
	_value = 0
