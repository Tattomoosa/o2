@tool
class_name RangeResource
extends FloatResource

const Signals := H.Signals

@export var max_value: FloatResource = FloatResource.new(1.0):
	set(v):
		Signals.swap(max_value, v, "value_changed", _changed)
		max_value = v
		_changed()
@export var min_value: FloatResource = FloatResource.new(0.0):
	set(v):
		Signals.swap(min_value, v, "value_changed", _changed)
		min_value = v
		_changed()
@export var allow_greater := false:
	set(v):
		allow_greater = v
		_changed()
@export var allow_lesser := false:
	set(v):
		allow_lesser = v
		_changed()

# Ignore overrides
func set_override_property_info(_property_info: Dictionary) -> void:
	return

func _validate_property(property: Dictionary) -> void:
	super(property)
	if property.name == "value":
		property.hint = PROPERTY_HINT_RANGE
		property.hint_string = "%f,%f" % [min_value.value, max_value.value]
		if allow_greater:
			property.hint_string += ",or_greater"
		if allow_lesser:
			property.hint_string += ",or_less"
	elif property.name in ["min_value", "max_value"]:
		property.usage |= PROPERTY_USAGE_UPDATE_ALL_IF_MODIFIED

func _changed() -> void:
	_set_value(value)
	emit_changed()
	notify_property_list_changed()

func _set_value(v: Variant) -> void:
	if v >= max_value.value:
		v = v if allow_greater else max_value.value
	if v <= min_value.value:
		v = v if allow_lesser else min_value.value
	super(v)

func _init(p_value = 1.0) -> void:
	super(p_value)