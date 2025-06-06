@tool
@icon("../assets/icons/Plane.svg")
class_name PlaneResource
extends VariantResource

@export var value : Plane:
	get: return _value
	set(v): _set_value(v)

func _init() -> void:
	_type = TYPE_PLANE
	_value = Plane()
