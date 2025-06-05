@tool
class_name BoolResource
extends VariantResource

@export_custom(PROPERTY_HINT_NONE, "expose_value")
var value : bool:
	get:
		return _value
	set(v):
		_value = v
		emit_changed()

func _init() -> void:
	_type = TYPE_BOOL
	_value = false
