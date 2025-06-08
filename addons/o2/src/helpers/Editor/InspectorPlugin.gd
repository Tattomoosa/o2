@tool
extends EditorInspectorPlugin

const _PropertyInfo := O2.Helpers.PropertyInfo
static var _FAKE_RESOURCE := _FakeResource.new()

func _parse_property(
	object: Object,
	type: Variant.Type,
	name: String,
	hint_type: PropertyHint,
	hint_string: String,
	usage_flags: int,
	wide: bool
) -> bool:
	if object is _FakeResource:
		return false
	return _parse_extended_property(object, type, name, hint_type, hint_string, usage_flags, wide)

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
	var property := _PropertyInfo.get_property(object, name)
	return instantiate_property_editor(object, property)

static func instantiate_property_editor(object: Object, property: Dictionary) -> EditorProperty:
	var pe := EditorInspector.instantiate_property_editor(
		_FAKE_RESOURCE,
		property.type if "type" in property else "",
		property.name if "name" in property else "",
		property.hint,
		property.hint_string if property.hint_string else "",
		property.usage
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

static func instantiate_patched_property_editor(
	object: Object,
	property: Dictionary,
	patch_script: Script
) -> EditorProperty:
	var property_editor := instantiate_property_editor(object, property)
	property_editor.set_script(patch_script)
	# property_editor.set_object_and_property(object, property.name)
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

class _FakeResource extends Resource:
	pass