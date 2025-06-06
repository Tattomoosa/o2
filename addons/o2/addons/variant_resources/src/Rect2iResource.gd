@tool
class_name Rect2iResource
extends VariantResource

@export var value : Rect2i:
	get: return _value
	set(v): _set_value(v)

func _init() -> void:
	_type = TYPE_RECT2I
	_value = Rect2i()