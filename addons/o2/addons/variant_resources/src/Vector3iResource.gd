@tool
class_name Vector3iResource
extends VariantResource

@export var value : Vector3i:
	get: return _value
	set(v): _set_value(v)

func _init() -> void:
	_type = TYPE_VECTOR3I
	_value = Vector3i.ZERO