@tool
@icon("../../assets/icons/Vector2.svg")
class_name Vector2Resource
extends VariantResource

@export var value : Vector2:
	get: return _value
	set(v): _set_value(v)

var x : float:
	get: return _value.x
	set(v): _set_value(Vector2(v, _value.y))
var y : float:
	get: return _value.y
	set(v): _set_value(Vector2(_value.x, v))


func _init() -> void:
	_type = TYPE_VECTOR2
	_value = Vector2.ZERO

func get_type() -> Variant.Type:
	return TYPE_VECTOR2