@tool
class_name IntResource
extends VariantResource

@export_custom(PROPERTY_HINT_NONE, "expose_value")
var value : int:
	get: return _value
	set(v):
		_value = v
		emit_changed()

func _init() -> void:
	_type = TYPE_INT
	_value = 0
