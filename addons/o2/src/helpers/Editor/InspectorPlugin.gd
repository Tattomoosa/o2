@tool
extends EditorInspectorPlugin

const CONTEXT_MENU_META_PROPERTY_NAME := &"editor_property_context_items"
const PropertyInfo := O2.Helpers.PropertyInfo
static var _FAKE_RESOURCE := _FakeResource.new()

# TODO
var _bottom_editor : Control

func _parse_property(
	object: Object,
	type: Variant.Type,
	name: String,
	hint_type: PropertyHint,
	hint_string: String,
	usage_flags: int,
	wide: bool
) -> bool:
	# Needed to always be able to generate a default property editor
	if object is _FakeResource:
		return false
	return _parse_extended_property(object, type, name, hint_type, hint_string, usage_flags, wide)

## Extending classes should override this method instead of _parse_property
func _parse_extended_property(
	_object: Object,
	_type: Variant.Type,
	_name: String,
	_hint_type: PropertyHint,
	_hint_string: String,
	_usage_flags: int,
	_wide: bool
) -> bool:
	return false

static func instantiate_default_property_editor(object: Object, name: String) -> EditorProperty:
	var property := PropertyInfo.get_property(object, name)
	return instantiate_property_editor(object, property, true)

static func instantiate_property_editor(object: Object, property: Dictionary, init_with_fake_resource := false) -> EditorProperty:
	if !object:
		push_error("Object is null")
		return null
	# TODO is this true?
	if "name" not in property:
		push_error("Cannot make property editor for anonymous property")
		return null
	var pe := EditorInspector.instantiate_property_editor(
		object if !init_with_fake_resource else _FAKE_RESOURCE,
		property.type if "type" in property else 0,
		property.name,
		property.hint if "hint" in property else 0,
		property.hint_string if "hint_string" in property else "",
		property.usage if "hint" in property else 0
	)
	pe.set_object_and_property(object, property.name)
	pe.ready.connect(pe.update_property)
	pe.property_changed.connect(
		func(
			property_name: StringName,
			value: Variant,
			_field: StringName,
			_changing: bool,
		) -> void:
			object.set(property_name, value)
			pe.update_property()
	)
	return pe

## Callable(PropertyEditor)
static func create_context_menu_item(item_name: String, callable: Callable, ep: EditorProperty) -> void:
	var items : Array = O2.Helpers.Metadata.get_or_add_meta(ep, CONTEXT_MENU_META_PROPERTY_NAME, [])
	items.push_back({"name": item_name, "callable": callable})

## Creates a property editor and attaches a script to it
static func instantiate_patched_property_editor(
	object: Object,
	property: Dictionary,
	patch_script: Script
) -> EditorProperty:
	var property_editor := instantiate_property_editor(object, property, true)
	assert(
		property_editor.get_script() == null,
		"EditorProperty for %s.%s already has script attached" % [object, property.name]
	)
	property_editor.set_script(patch_script)
	return property_editor

static func style_inspector_button(button: Button, icon_name: String = "") -> void:
	var inspector := EditorInterface.get_inspector()
	if icon_name:
		button.add_theme_icon_override("icon", inspector.get_theme_icon(icon_name, &"EditorIcons"))
	for status in ["normal", "disabled", "hover", "pressed"]:
		button.add_theme_stylebox_override(
			status,
			inspector.get_theme_stylebox(status, &"InspectorActionButton")
		)

static func property_is_in_bottom_editor(property: Dictionary) -> bool:
	if "type" in property:
		if property.type in [
			TYPE_ARRAY,
			TYPE_DICTIONARY,
			TYPE_PACKED_BYTE_ARRAY,
			TYPE_PACKED_INT32_ARRAY,
			TYPE_PACKED_INT64_ARRAY,
			TYPE_PACKED_FLOAT32_ARRAY,
			TYPE_PACKED_FLOAT64_ARRAY,
			TYPE_PACKED_STRING_ARRAY,
			TYPE_PACKED_VECTOR2_ARRAY,
			TYPE_PACKED_VECTOR3_ARRAY,
			TYPE_PACKED_COLOR_ARRAY,
			TYPE_PACKED_VECTOR4_ARRAY,
		]:
			return true
	var editor_settings := EditorInterface.get_editor_settings()
	if editor_settings:
		if editor_settings.get_setting("interface/inspector/horizontal_vector_types_editing")\
		and property.type in [
				TYPE_VECTOR3,
				TYPE_VECTOR3I,
				TYPE_VECTOR4,
				TYPE_VECTOR4I,
				TYPE_RECT2,
				TYPE_RECT2I,
				TYPE_PLANE,
				TYPE_QUATERNION,
			]:
				return true
		if editor_settings.get_setting("interface/inspector/horizontal_vector2_editing")\
		and property.type in [TYPE_VECTOR2, TYPE_VECTOR2I]:
			return true
	if "hint" in property:
		match property.hint:
			PROPERTY_HINT_MULTILINE_TEXT:
				return true
			PROPERTY_HINT_ARRAY_TYPE:
				return true
			PROPERTY_HINT_DICTIONARY_TYPE:
				return true
			PROPERTY_HINT_LAYERS_2D_NAVIGATION,\
			PROPERTY_HINT_LAYERS_2D_PHYSICS,\
			PROPERTY_HINT_LAYERS_2D_RENDER,\
			PROPERTY_HINT_LAYERS_3D_NAVIGATION,\
			PROPERTY_HINT_LAYERS_3D_PHYSICS,\
			PROPERTY_HINT_LAYERS_3D_RENDER,\
			PROPERTY_HINT_LAYERS_AVOIDANCE:
				return true
			PROPERTY_HINT_TYPE_STRING:
				return true
	return false

class _FakeResource extends Resource:
	pass