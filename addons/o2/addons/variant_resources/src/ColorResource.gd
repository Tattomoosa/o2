@tool
@icon("../assets/icons/Color.svg")
class_name ColorResource
extends VariantResource

## Color value
@export var value : Color:
	get: return _value
	set(v): _set_value(v)

func _init() -> void:
	_type = TYPE_COLOR
	_value = Color.BLACK