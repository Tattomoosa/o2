@tool
class_name FloatResource
extends VariantResource

## Float value
@export var value : float:
	get: return _value
	set(v): _set_value(v)

func _init() -> void:
	_type = TYPE_FLOAT
	_value = 0.0
