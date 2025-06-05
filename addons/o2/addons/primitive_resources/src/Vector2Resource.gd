@tool
class_name Vector2Resource
extends VariantResource

@export_custom(PROPERTY_HINT_NONE, "expose_value")
var value : Vector2:
	get: return _value
	set(v):
		_value = v
		emit_changed()

func _init() -> void:
	_type = TYPE_VECTOR2
	_value = Vector2.ZERO