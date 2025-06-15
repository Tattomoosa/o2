@tool
@icon("../../assets/icons/Vector4i.svg")
class_name Vector4iResource
extends VariantResource

@export var value : Vector4i:
	get: return _value
	set(v): _set_value(v)

var x : int:
	get: return _value.x
	set(v): _set_value(Vector4(v, _value.y, _value.z, _value.w))
var y : int:
	get: return _value.y
	set(v): _set_value(Vector4(_value.x, v, _value.z, _value.w))
var z : int:
	get: return _value.z
	set(v): _set_value(Vector4(_value.x, _value.y, v, _value.w))
var w : int:
	get: return _value.w
	set(v): _set_value(Vector4(_value.x, _value.y, _value.z, v))

func _init() -> void:
	_type = TYPE_VECTOR4I
	_value = Vector4i.ZERO

func get_type() -> Variant.Type:
	return TYPE_VECTOR4I