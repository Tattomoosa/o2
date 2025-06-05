@tool
class_name FloatResource
extends VariantResource

@export_custom(PROPERTY_HINT_NONE, "expose_value")
var value : float:
	get: return _value
	set(v):
		_value = v
		emit_changed()

func _init() -> void:
	_type = TYPE_FLOAT
	_value = 0.0
