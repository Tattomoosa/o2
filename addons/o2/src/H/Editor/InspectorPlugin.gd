@tool
extends EditorInspectorPlugin

const EditorInspectorContextMenu := O2.EditorExtensions.EditorInspectorContextMenu
const PropertyInfo := H.PropertyInfo
const Scripts := H.Scripts
const Nodes := H.Nodes
# Needed to always be able to generate a default property editor
# that bypasses any other plugins (that extend from this class, at least)
static var _FAKE_RESOURCE := _FakeResource.new()

func _can_handle(_object: Object) -> bool:
	return true

func can_patch(_ep: EditorProperty) -> bool:
	return false

func patch(ep: EditorProperty) -> EditorProperty:
	return ep

func _parse_property(
	object: Object,
	type: Variant.Type,
	name: String,
	hint_type: PropertyHint,
	hint_string: String,
	usage_flags: int,
	wide: bool
) -> bool:
	# if name == "script":
	# 	var script_name := Scripts.get_class_name_or_script_name(get_script())
	# 	O2.logger.debug(script_name, " parsing properties...")
	if object is _FakeResource:
		return false
	return parse_property(object, type, name, hint_type, hint_string, usage_flags, wide)

func _parse_end(object: Object) -> void:
	var editor_properties := Nodes.get_descendents_with_type(
		EditorInterface.get_inspector(),
		EditorProperty,
	)
	for ep in editor_properties:
		if can_patch(ep):
			patch(ep)
	parse_end(object)

func parse_end(_object: Object) -> void:
	pass

## Extending classes should override this method instead of _parse_property,
## This ensures "instantiate_default_property_editor" will work!
##
## Anything fancy should probably be done in "patch" though.
func parse_property(
	_object: Object,
	_type: Variant.Type,
	_name: String,
	_hint_type: PropertyHint,
	_hint_string: String,
	_usage_flags: int,
	_wide: bool
) -> bool:
	return false

func instantiate_default_property_editor(object: Object, name: String) -> EditorProperty:
	var property := PropertyInfo.get_property(object, name)
	return instantiate_property_editor(object, property, true)

func instantiate_property_editor(object: Object, property: Dictionary, init_with_fake_resource := false) -> EditorProperty:
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
func add_context_menu_item(
	object: Object,
	property_name: String, 
	item_name: String,
	callable: Callable,
) -> void:
	EditorInspectorContextMenu.add_context_menu_item(object, property_name, item_name, callable)

func add_heading(icon: Texture2D, text: String) -> void:
	var inspector := EditorInterface.get_inspector()
	var heading := PanelContainer.new()
	heading.add_theme_stylebox_override("panel", inspector.get_theme_stylebox("bg", &"EditorInspectorCategory"))
	var h_hbox := HBoxContainer.new()
	# TODO separation

	h_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	heading.add_child(h_hbox)
	var trect := TextureRect.new()
	trect.texture = icon
	trect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	h_hbox.add_child(trect)
	var l := Label.new()
	l.theme_type_variation = "HeaderSmall"
	l.text = "Metadata Scripts"
	l.add_theme_constant_override("line_spacing", 0)
	l.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
	h_hbox.add_child(l)
	add_custom_control(heading)

## Creates a property editor and attaches a script to it
func instantiate_patched_property_editor(
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

static func style_inspector_button(button: Button, icon_name: String = "") -> Button:
	var inspector := EditorInterface.get_inspector()
	if icon_name:
		button.add_theme_icon_override("icon", inspector.get_theme_icon(icon_name, &"EditorIcons"))
	for status in ["normal", "disabled", "hover", "pressed"]:
		button.add_theme_stylebox_override(
			status,
			inspector.get_theme_stylebox(status, &"InspectorActionButton")
		)
	return button

static func get_panel_style(style_name: String, theme_type: String) -> StyleBox:
	var inspector := EditorInterface.get_inspector()
	return inspector.get_theme_stylebox(style_name, theme_type)

func get_icon(icon_name: String) -> Texture2D:
	var inspector := EditorInterface.get_inspector()
	return inspector.get_theme_icon(icon_name, &"EditorIcons")

func create_foldable_container() -> FoldableContainer:
	var inspector := EditorInterface.get_inspector()
	var panel := FoldableContainer.new()
	var stylebox := inspector.get_theme_stylebox("Content", &"EditorStyles")
	panel.add_theme_stylebox_override(
		"panel",
		stylebox
	)
	panel.add_theme_color_override("hover_font_color", panel.get_theme_color("font_color"))
	panel.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	panel.add_theme_stylebox_override("title_collapsed_hover_panel", stylebox)
	panel.add_theme_stylebox_override("title_collapsed_panel", stylebox)
	panel.add_theme_stylebox_override("title_hover_panel", stylebox)
	panel.add_theme_stylebox_override("title_panel", stylebox)
	return panel

static func get_property(object: Object, name: String) -> Dictionary:
	return H.PropertyInfo.get_property(object, name)

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