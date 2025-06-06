@tool
class_name RangeResource
extends FloatResource

@export var max_value: FloatResource = FloatResource.new(1.0):
	set(v):
		max_value = v
		emit_changed()
@export var min_value: FloatResource = FloatResource.new(0.0):
	set(v):
		min_value = v
		emit_changed()
@export var allow_greater := false
@export var allow_lesser := false

func _set_value(v: Variant) -> void:
	if v >= max_value.value:
		v = v if allow_greater else max_value.value
	if v <= min_value.value:
		v = v if allow_lesser else min_value.value
	super(v)

func _init(p_value = 1.0) -> void:
	super(p_value)