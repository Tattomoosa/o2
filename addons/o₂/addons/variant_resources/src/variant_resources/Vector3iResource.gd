@tool
@icon("../../assets/icons/Vector3i.svg")
class_name Vector3iResource
extends VariantResource

@export var value : Vector3i:
	get: return _value
	set(v): _set_value(v)

var x : int:
	get: return _value.x
	set(v): _set_value(Vector3(v, _value.y, _value.z))
var y : int:
	get: return _value.y
	set(v): _set_value(Vector3(_value.x, v, _value.z))
var z : int:
	get: return _value.z
	set(v): _set_value(Vector3(_value.x, _value.y, v))


func _init() -> void:
	_type = TYPE_VECTOR3I
	_value = Vector3i.ZERO

func get_type() -> Variant.Type:
	return TYPE_VECTOR3I