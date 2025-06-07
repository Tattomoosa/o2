@tool
class_name MetadataScript_SyncVariantResource
extends MetadataScript

## Requires MetadataScript plugin

const _PropertyInfo := O2.Helpers.PropertyInfo
const _BitMasks := O2.Helpers.BitMasks

@export var resource : VariantResource:
	set(v):
		_Signals.swap(resource, v, "value_changed", _update)
		resource = v
		if Engine.is_editor_hint() and node:
			_patch_property_name_into_valid_property_enum()
		_update()
@export var property_name : StringName:
	set(v):
		property_name = v
		_update()

var _property_name_property : Dictionary = {
	"hint": PROPERTY_HINT_ENUM_SUGGESTION,
	"hint_string": ""
}

func _enter_tree() -> void:
	_patch_property_name_into_valid_property_enum()

func _update() -> void:
	if !node:
		return
	if resource and property_name:
		node.set(property_name, resource.get("value"))

func _validate_property(property: Dictionary) -> void:
	if !Engine.is_editor_hint():
		return
	if property.name == "property_name":
		property.hint = _property_name_property.hint
		property.hint_string = _property_name_property.hint_string

func _patch_property_name_into_valid_property_enum() -> void:
	var p := _property_name_property
	if node and resource:
		p.hint = PROPERTY_HINT_ENUM_SUGGESTION
		var hint_strings : Array[String] = []
		for property in node.get_property_list():
			if _can_sync_to_property(property):
				hint_strings.append(property.name)
		p.hint_string = ",".join(hint_strings)
	else:
		p.hint = PROPERTY_HINT_NONE
		p.hint_string = ""
	notify_property_list_changed()

func _can_sync_to_property(property: Dictionary) -> bool:
	if !property:
		return false
	if !_BitMasks.get_bit_value(property.usage, PROPERTY_USAGE_NO_EDITOR):
		return false
	if resource is FlagsResource:
		return _PropertyInfo.property_is_bitflags(property)
	return property.type == resource.get_type()
