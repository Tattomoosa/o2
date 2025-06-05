@tool
class_name IntResource
extends VariantResource

@export var value : int:
	get: return _value
	set(v): _set_value(v)

func _init() -> void:
	_type = TYPE_INT
	_value = 0
