@tool
@icon("../../assets/icons/Vector2i.svg")
class_name Vector2iResource
extends VariantResource

@export var value : Vector2i:
	get: return _value
	set(v): _set_value(v)

func _init() -> void:
	_type = TYPE_VECTOR2I
	_value = Vector2i.ZERO

func get_type() -> Variant.Type:
	return TYPE_VECTOR2I