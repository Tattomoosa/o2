@tool
class_name ColorResource
extends VariantResource

## Color value
@export_custom(PROPERTY_HINT_NONE, "expose_value")
var value : Color:
	get: return _value
	set(v):
		_value = v
		emit_changed()

func _init() -> void:
	_type = TYPE_COLOR
	_value = Color.BLACK