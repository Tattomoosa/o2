@tool
class_name Rect2Resource
extends VariantResource

@export var value : Rect2:
	get: return _value
	set(v): _set_value(v)

func _init() -> void:
	_type = TYPE_RECT2
	_value = Rect2()