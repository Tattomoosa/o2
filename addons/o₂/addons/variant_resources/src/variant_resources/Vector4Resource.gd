@tool
@icon("../../assets/icons/Vector4.svg")
class_name Vector4Resource
extends VariantResource

@export var value : Vector4:
	get: return _value
	set(v): _set_value(v)

var x : float:
	get: return _value.x
	set(v): _set_value(Vector4(v, _value.y, _value.z, _value.w))
var y : float:
	get: return _value.y
	set(v): _set_value(Vector4(_value.x, v, _value.z, _value.w))
var z : float:
	get: return _value.z
	set(v): _set_value(Vector4(_value.x, _value.y, v, _value.w))
var w : float:
	get: return _value.w
	set(v): _set_value(Vector4(_value.x, _value.y, _value.z, v))


func _init() -> void:
	_type = TYPE_VECTOR4
	_value = Vector4.ZERO

func get_type() -> Variant.Type:
	return TYPE_VECTOR4