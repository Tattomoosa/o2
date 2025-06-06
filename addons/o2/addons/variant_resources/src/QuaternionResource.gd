@tool
@icon("../assets/icons/Quaternion.svg")
class_name QuaternionResource
extends VariantResource

@export var value : Quaternion:
	get: return _value
	set(v): _set_value(v)

func _init() -> void:
	_type = TYPE_QUATERNION
	_value = Quaternion()
