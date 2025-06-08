@tool
@icon("../../assets/icons/Vector3i.svg")
class_name Vector3iResource
extends VariantResource

@export var value : Vector3i:
	get: return _value
	set(v): _set_value(v)

func _init() -> void:
	_type = TYPE_VECTOR3I
	_value = Vector3i.ZERO

func get_type() -> Variant.Type:
	return TYPE_VECTOR3I