@tool
@icon("../../assets/icons/float.svg")
class_name FloatResource
extends VariantResource

## Float value
@export var value : float:
	get: return _value
	set(v): _set_value(v)

func _init(p_value = 0.0) -> void:
	_type = TYPE_FLOAT
	_value = p_value

func get_type() -> Variant.Type:
	return TYPE_FLOAT