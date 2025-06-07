@tool
@icon("../../assets/icons/AABB.svg")
class_name AABBResource
extends VariantResource

## Boolean value
@export var value : AABB:
	get: return _value
	set(v): _set_value(v)

func _init() -> void:
	_type = TYPE_AABB
	_value = AABB()
