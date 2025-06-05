@tool
class_name VariantResource
extends Resource

@export var type : Variant.Type = TYPE_NIL:
	get: return _type
	set(value):
		_type = value
		notify_property_list_changed()
		emit_changed()

var _value : Variant = null
var _type : Variant.Type = TYPE_NIL

func _validate_property(property: Dictionary) -> void:
	if property.name == "type":
		property.usage |= PROPERTY_USAGE_UPDATE_ALL_IF_MODIFIED
		if O2.Helpers.Scripts.get_script_name(self)  != "VariantResource":
			property.usage |= PROPERTY_USAGE_READ_ONLY | PROPERTY_USAGE_EDITOR
	if property.name == "value":
		property.hint_string = "expose_value"

func _get_property_list() -> Array[Dictionary]:
	var props : Array[Dictionary] = []
	if O2.Helpers.Scripts.get_script_name(self)  != "VariantResource":
		return props
	if type != TYPE_NIL:
		props.append({
			"name": "value",
			"type": type,
		})
	return props

func _get(property: StringName) -> Variant:
	if property == "value" and typeof(_value) == type:
		return _value
	return null

func _set(property: StringName, v: Variant) -> bool:
	print("SET in VariantResource")
	if property == "value":
		_set_value(v)
		return true
	return false

func get_type() -> Variant.Type:
	return _type

func _value_should_update(p_value: Variant) -> bool:
	return typeof(p_value) == type and p_value != _value

func _set_value(v: Variant) -> void:
	if _value_should_update(v):
		_value = v
		emit_changed()