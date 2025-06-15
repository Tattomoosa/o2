@tool
@icon("../../assets/icons/Projection.svg")
class_name ProjectionResource
extends VariantResource

@export var value : Projection:
	get: return _value
	set(v): _set_value(v)

func _init() -> void:
	_type = TYPE_PROJECTION
	_value = Projection()

func get_type() -> Variant.Type:
	return TYPE_PROJECTION