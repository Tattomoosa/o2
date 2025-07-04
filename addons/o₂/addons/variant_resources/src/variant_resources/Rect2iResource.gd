@tool
@icon("../../assets/icons/Rect2i.svg")
class_name Rect2iResource
extends VariantResource

@export var value : Rect2i:
	get: return _value
	set(v): _set_value(v)

func _init() -> void:
	_type = TYPE_RECT2I
	_value = Rect2i()

func get_type() -> Variant.Type:
	return TYPE_RECT2I