@tool
@icon("../../assets/icons/Transform3D.svg")
class_name Transform3DResource
extends VariantResource

@export var value : Transform3D:
	get: return _value
	set(v): _set_value(v)

func _init() -> void:
	_type = TYPE_TRANSFORM3D
	_value = Transform3D()