@tool
@icon("../../assets/icons/Vector2i.svg")
class_name Vector2iResource
extends VariantResource

@export var value : Vector2i:
	get: return _value
	set(v): _set_value(v)

var x : int:
	get: return _value.x
	set(v): _set_value(Vector2(v, _value.y))
var y : int:
	get: return _value.y
	set(v): _set_value(Vector2(_value.x, v))

func _init() -> void:
	_type = TYPE_VECTOR2I
	_value = Vector2i.ZERO

func get_type() -> Variant.Type:
	return TYPE_VECTOR2I