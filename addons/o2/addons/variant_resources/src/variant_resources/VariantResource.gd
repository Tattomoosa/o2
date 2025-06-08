@tool
@icon("../../assets/icons/Variant.svg")
class_name VariantResource
extends Resource

signal value_changed

@export var type : Variant.Type = TYPE_NIL:
	get: return _type
	set(value):
		_type = value
		emit_changed()
		notify_property_list_changed()

var _value : Variant = null
var _type : Variant.Type = TYPE_NIL
var _override_property_hint : Dictionary = {}

func _validate_property(property: Dictionary) -> void:
	if property.name == "value" and _override_property_hint:
		for key in _override_property_hint:
			property[key] = _override_property_hint[key]
	if property.name == "type":
		property.usage |= PROPERTY_USAGE_UPDATE_ALL_IF_MODIFIED
		if not is_variant():
			property.usage |= PROPERTY_USAGE_READ_ONLY | PROPERTY_USAGE_EDITOR

func _get_property_list() -> Array[Dictionary]:
	var props : Array[Dictionary] = []
	if not is_variant():
		return props
	if type != TYPE_NIL:
		props.append({
			"name": "value",
			"type": type,
		})
	return props

func _get(property: StringName) -> Variant:
	if property == "value":
		if typeof(_value) == type:
			return _value
		else:
			_value = type_convert(_value, type)
			return _value
	return null

func _set(property: StringName, v: Variant) -> bool:
	if property == "value":
		_set_value(v)
		return true
	return false

func is_variant() -> bool:
	return (get_script() as Script).get_global_name() == "VariantResource"

func get_type() -> Variant.Type:
	return _type

func _value_should_update(p_value: Variant) -> bool:
	return typeof(p_value) == type and p_value != _value

func _set_value(v: Variant) -> void:
	if !_value_should_update(v):
		return
	_value = v
	value_changed.emit()