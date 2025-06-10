@tool
extends O2.Helpers.Editor.InspectorPlugin

const ES := O2.Helpers.Editor.Settings
const InspectorPlugin := preload("VariantResourceInspector.gd")
const Controls := O2.Helpers.Controls
const H := O2.Helpers
const RESOURCE_ICON := preload("uid://b3hbc21pvf0fs")
const RESOURCE_OVERRIDE_ICON := preload("uid://cmhsyh2bllenw")
const SYNC_RESOURCE_PROCESS_ICON := preload("uid://bfqtnpcim5od6")
const SYNC_RESOURCE_PHYSICS_ICON := preload("uid://ciejl2enkdkyp")

const TYPE_MAP : Dictionary[Variant.Type, String] = {
	TYPE_BOOL: "BoolResource",
	TYPE_INT: "IntResource",
	TYPE_FLOAT: "FloatResource",
	TYPE_STRING: "StringResource",
	TYPE_VECTOR2: "Vector2Resource",
	TYPE_VECTOR2I: "Vector2iResource",
	TYPE_VECTOR3: "Vector3Resource",
	TYPE_VECTOR3I: "Vector3iResource",
	TYPE_TRANSFORM2D: "Transform2DResource",
	TYPE_VECTOR4: "Vector4Resource",
	TYPE_VECTOR4I: "Vector4iResource",
	TYPE_PLANE: "PlaneResource",
	TYPE_QUATERNION: "QuaternionResource",
	TYPE_AABB: "AABBResource",
	TYPE_BASIS: "BasisResource",
	TYPE_TRANSFORM3D: "Transform3DResource",
	TYPE_PROJECTION: "ProjectionResource",
	TYPE_COLOR: "ColorResource",
	TYPE_STRING_NAME: "StringNameResource",
	TYPE_NODE_PATH: "NodePathResource",
	# TYPE_RID: "RIDResource"
	# TYPE_OBJECT: "ObjectResource"
	# TYPE_CALLABLE: "CallableResource"
	# TYPE_SIGNAL: "SignalResource"
	TYPE_DICTIONARY: "DictionaryResource",
	TYPE_ARRAY: "ArrayResource",
	TYPE_PACKED_BYTE_ARRAY: "PackedByteArrayResource",
	TYPE_PACKED_INT32_ARRAY: "PackedInt32ArrayResource",
	TYPE_PACKED_INT64_ARRAY: "PackedInt64ArrayResource",
	TYPE_PACKED_FLOAT32_ARRAY: "PackedFloat32ArrayResource",
	TYPE_PACKED_FLOAT64_ARRAY: "PackedFloat64ArrayResource",
	TYPE_PACKED_STRING_ARRAY: "PackedStringArrayResource",
	TYPE_PACKED_VECTOR2_ARRAY: "PackedVector2ArrayResource",
	TYPE_PACKED_VECTOR3_ARRAY: "PackedVector3ArrayResource",
	TYPE_PACKED_COLOR_ARRAY: "PackedColorArrayResource",
	TYPE_PACKED_VECTOR4_ARRAY: "PackedVector4ArrayResource",
}

const IGNORE_USAGE : Array[int] = [ PROPERTY_USAGE_INTERNAL ]

func _can_handle(_object: Object) -> bool:
	return true

func _parse_extended_property(object: Object, type: Variant.Type, name: String, hint_type: PropertyHint, hint_string: String, _usage_flags: int, _wide: bool) -> bool:
	if !name:
		return false
	if type == TYPE_OBJECT and hint_type == PROPERTY_HINT_RESOURCE_TYPE:
		if !O2.Helpers.Scripts.is_class_name(hint_string):
			return false
		if !O2.Helpers.Scripts.class_name_extends_from(hint_string, "VariantResource"):
			return false
		add_property_editor(name, _create_resource_editor(object, name))
		return true
	elif object is Node and type in TYPE_MAP:
		var overridden_property_editor := _get_override_resource_editor(object, name)
		if overridden_property_editor:
			add_property_editor(name, overridden_property_editor)
			return true
		else:
			var variant_editor = _create_variant_editor(object, name)
			add_property_editor(name, variant_editor)
			return true
	return false

func _add_resource_override(object: Object, property_name: String) -> void:
	if object is not Node:
		push_error("%s is not a Node!" % object)

	if object is Range and property_name in ["value", "min_value", "max_value"]:
		var range_node := object as Range
		var rr := RangeResource.new()
		rr.value = range_node.value
		rr.min_value.value = range_node.min_value
		rr.max_value.value = range_node.max_value
		for p_name in ["value", "min_value", "max_value"]:
			var script := MetadataScript_SyncVariantResource.new()
			script.property_name = p_name
			if p_name == "value":
				script.resource = rr
			else:
				script.resource = rr.get(p_name)
			script.add_to_node(range_node)
		range_node.notify_property_list_changed()
		return

	var value : Variant = object.get(property_name)
	var type := typeof(value)
	var variant_resource_class_name := TYPE_MAP[type]
	var vr : VariantResource = H.Scripts.get_script_from_class_name(variant_resource_class_name).new()
	var md_script := MetadataScript_SyncVariantResource.new()
	md_script.resource = vr
	md_script.property_name = property_name
	md_script.add_to_node(object)
	object.notify_property_list_changed()

func _create_variant_editor(object: Object, property_name: String) -> EditorProperty:
	var variant_editor := instantiate_default_property_editor(
		object,
		property_name
	)
	_add_override_context_menu_item(variant_editor)
	return variant_editor

func _create_resource_editor(object: Object, property_name: String) -> EditorProperty:
	var property := PropertyInfo.get_property(object, property_name)
	var resource_editor : VariantResourceEditorProperty = instantiate_patched_property_editor(
		object,
		property,
		VariantResourceEditorProperty
	)
	var resource : VariantResource = object.get(property_name)
	if resource:
		resource_editor.property_definition = PropertyInfo.get_property(resource, "value")
	else:
		resource_editor.property_definition = property
	return resource_editor

func _get_override_resource_editor(object: Object, property_name: String) -> EditorProperty:
	if !object.has_meta("metadata_scripts"):
		return null
	var object_property := PropertyInfo.get_property(object, property_name)
	var metadata_scripts : Array = object.get_meta("metadata_scripts")
	for md_script in metadata_scripts:
		if md_script is MetadataScript_SyncVariantResource:
			var s := md_script as MetadataScript_SyncVariantResource
			if md_script.property_name != property_name:
				continue
			if !md_script.resource:
				return null
			var property := PropertyInfo.get_property(s, "resource")
			property.hint_string = TYPE_MAP[object_property.type]
			var resource_editor := instantiate_patched_property_editor(s, property, VariantResourceOverrideEditorProperty)
			var vr_editor := resource_editor as VariantResourceOverrideEditorProperty
			vr_editor.label = property_name.to_pascal_case()
			vr_editor.metadata_script = s
			vr_editor.original_object = object
			vr_editor.property_definition = object_property
			var overridden_editor_property := OverriddenEditorProperty.new()
			overridden_editor_property.resource_editor = vr_editor
			return overridden_editor_property
	return null

func _add_override_context_menu_item(ep: EditorProperty) -> void:
	create_context_menu_item(
		"Add Property Override Resource",
		_add_resource_override.bindv(
			[ep.get_edited_object(), ep.get_edited_property()]
		).unbind(1),
		ep
	)

static func get_resource_override_metadata_script(object: Object, property_name: String) -> MetadataScript_SyncVariantResource:
	var metadata_scripts : Array = object.get_meta("metadata_scripts")
	for md_script in metadata_scripts:
		if !md_script is MetadataScript_SyncVariantResource:
			continue
		var s := md_script as MetadataScript_SyncVariantResource
		if s.property_name != property_name:
			continue
		return s
	return null

class VariantResourceEditorProperty extends EditorProperty:
	var picker : EditorResourcePicker
	var picker_button : Button
	var picker_internal_hbox : HBoxContainer
	var value_editor : EditorProperty
	var value_editor_parent : Control
	var use_bottom_editor := false
	var resource_name_label : Label
	var property_definition : Dictionary
	var resource_class_name : String

	signal using_bottom_editor(node: Node)

	func _ready() -> void:
		use_bottom_editor = _should_use_bottom_editor()
		var resource := _get_resource()
		picker = get_child(0)
		picker_button = picker.get_child(0)

		var vbox := VBoxContainer.new()
		vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		vbox.add_theme_constant_override("separation", 0)
		value_editor_parent = vbox

		var mc := Controls.margin_container(ES.scale_int(0))

		picker_internal_hbox = HBoxContainer.new()
		picker_internal_hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var heading := Control.new()
		if resource:
			resource_class_name = O2.Helpers.Scripts.get_object_class_name(resource)
			if !use_bottom_editor:
				heading.custom_minimum_size.y = ES.scale * 12
				resource_name_label = Label.new()
				resource_name_label.add_theme_font_size_override("font_size", ES.scale * 10)
				resource_name_label.set_anchors_preset(PRESET_TOP_WIDE)
				resource_name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
				resource_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
				resource_name_label.position.y -= ES.scale * 6
				# resource_name_label.position.x += ES.scale * 12
				resource_name_label.z_index = 1
				_update_resource_name_label_text()
				heading.add_child(resource_name_label)
				value_editor_parent.add_child(heading, Control.INTERNAL_MODE_FRONT)

			value_editor = create_value_editor()
			resource.changed.connect(_replace_value_editor)
			var margin_container := Controls.margin_container(ES.scale * 2)
			value_editor_parent.add_child(margin_container)
			margin_container.add_child(value_editor)
			# value_editor_parent.add_child(value_editor)

			if use_bottom_editor:
				var bottom_panel := PanelContainer.new()
				# bottom_panel.add_theme_stylebox_override(
				# 	"panel",
				# 	get_theme_stylebox("sub_inspector_bg1", "EditorStyles")
				# )
				bottom_panel.add_child(value_editor_parent)
				value_editor_parent = bottom_panel

			# resource.property_list_changed.connect(_replace_value_editor)
		else:
			vbox.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN

		if !resource or use_bottom_editor:
			picker_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		else:
			picker_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
			picker_button.expand_icon = false

		if !use_bottom_editor:
			Controls.add_children(picker_internal_hbox, [value_editor_parent, picker_button])
		else:
			add_child(value_editor_parent)
			_set_bottom_editor(value_editor_parent)

		Controls.layout({
			control = self, children = [{
				control = mc, children = [{
					control = picker, children = [{
						control = picker_internal_hbox,
						internal = Control.INTERNAL_MODE_FRONT,
						children = [picker_button]
					}],
				}],
			}],
		})

		self.child_entered_tree.connect(_subinspector_entering)
		self.child_exiting_tree.connect(_subinspector_exiting)

		picker.resource_changed.connect(_on_resource_changed)
	
	func _set_bottom_editor(node: Node) -> void:
		set_bottom_editor(node)
		using_bottom_editor.emit(node)
	
	func _on_resource_changed(_resource: VariantResource) -> void:
		get_edited_object().notify_property_list_changed()

	func _get_resource() -> VariantResource:
		return get_edited_object().get(get_edited_property())
	
	func _replace_value_editor() -> void:
		if !value_editor.is_visible_in_tree():
			if !value_editor.visibility_changed.is_connected(_replace_value_editor):
				value_editor.visibility_changed.connect(_replace_value_editor, CONNECT_ONE_SHOT | CONNECT_DEFERRED)
			return
		_update_resource_name_label_text()
		var new_value_editor := create_value_editor()
		var parent := value_editor.get_parent()
		parent.add_child(new_value_editor)
		parent.remove_child(value_editor)
		value_editor.free()
		value_editor = new_value_editor
		_update_resource_name_label_text()

	func _create_value_editor() -> EditorProperty:
		return InspectorPlugin.instantiate_default_property_editor(
			_get_resource(),
			"value"
		)
	
	func create_value_editor() -> EditorProperty:
		var ve := _create_value_editor()
		ve.name_split_ratio = 0.0
		ve.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		return ve

	func _subinspector_entering(node: Node) -> void:
		if node is not EditorInspector:
			return
		value_editor_parent.hide()
		picker_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		using_bottom_editor.emit(node)

	func _subinspector_exiting(node: Node) -> void:
		if node is not EditorInspector:
			return
		value_editor_parent.show()
		if use_bottom_editor:
			_set_bottom_editor(value_editor_parent)
		else:
			picker_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
			using_bottom_editor.emit(null)
		value_editor.update_property()
	
	func _update_resource_name_label_text() -> void:
		if use_bottom_editor:
			return
		var resource := _get_resource()
		if resource.resource_name:
			resource_name_label.text = resource.resource_name
			resource_name_label.modulate = Color.WHITE
		else:
			resource_name_label.text = resource_class_name
			resource_name_label.modulate = Color(Color.WHITE, 0.4)
	
	func _property_can_revert(_property: StringName) -> bool:
		return false

	func _property_get_revert(_property: StringName) -> Variant:
		return _get_resource().value
	
	func _should_use_bottom_editor() -> bool:
		return O2.Helpers.Editor.InspectorPlugin.property_is_in_bottom_editor(property_definition)

class VariantResourceOverrideEditorProperty extends VariantResourceEditorProperty:
	var original_object : Object
	var metadata_script : Object

	func _ready() -> void:
		selectable = true
		set_object_and_property(metadata_script, get_edited_property())
		super()
		property_can_revert_changed.emit(property_definition.name, false)

		EditorInterface.get_inspector().property_selected.connect(_on_property_selected)
	
	# TODO needs to swap out for a new resource
	func _on_resource_changed(resource: VariantResource) -> void:
		get_edited_object().set(get_edited_property(), resource)
		update_property()
		_replace_value_editor()
	
	func _update_property() -> void:
		var value : Variant = original_object.get(property_definition.name)
		_get_resource().value = value
		value_editor.update_property()

	func _on_property_selected(p_name: String) -> void:
		if p_name == property_definition.name:
			select()
		else:
			deselect()

	func _create_value_editor() -> EditorProperty:
		var resource := _get_resource()
		resource.set_override_property_info(property_definition)
		var resource_property_info := PropertyInfo.get_property(resource, "value")

		return InspectorPlugin.instantiate_property_editor(
			_get_resource(),
			resource_property_info
		)

	func remove_override() -> void:
		var property_name : String = property_definition.name
		var scripts := MetadataScript.get_metadata_scripts(original_object)
		for script in scripts:
			if script is not MetadataScript_SyncVariantResource:
				continue
			var svr := script as MetadataScript_SyncVariantResource
			if svr.property_name == property_name:
				scripts.erase(svr)
				original_object.notify_property_list_changed()
				break
		
class OverriddenEditorProperty extends EditorProperty:
	var resource_editor : VariantResourceOverrideEditorProperty
	var mode_button : MenuButton

	func _ready() -> void:
		deletable = true
		name_split_ratio = 0.5

		var hbox := HBoxContainer.new()
		add_child(resource_editor)

		resource_editor.name_split_ratio = 0
		resource_editor.label = ""
		resource_editor.picker.reparent(hbox)

		mode_button = MenuButton.new()
		mode_button.flat = true
		mode_button.icon = _get_mode_icon(resource_editor.metadata_script.sync_mode)
		mode_button.expand_icon = false
		hbox.add_child(mode_button)
		add_child(hbox)

		if resource_editor.use_bottom_editor:
			set_bottom_editor(resource_editor)
		else:
			resource_editor.using_bottom_editor.connect(_set_bottom_editor)
		
		EditorInterface.get_inspector().property_deleted.connect(_on_deleted)

		var popup := mode_button.get_popup()
		popup.add_icon_item(RESOURCE_OVERRIDE_ICON, "Resource -> Property (Override)")
		popup.set_item_tooltip(0, "Every time the Resource's value changes, the property is updated")
		popup.add_icon_item(SYNC_RESOURCE_PROCESS_ICON, "Resource <-> Property (Process)")
		popup.set_item_tooltip(1, "The resource and the property are kept in sync every frame")
		popup.add_icon_item(SYNC_RESOURCE_PHYSICS_ICON, "Resource <-> Property (Physics Process)")
		popup.set_item_tooltip(2, "The resource and the property are kept in sync every physics frame")
		popup.index_pressed.connect(_popup_pressed)
	
	func _popup_pressed(index: int) -> void:
		resource_editor.metadata_script.sync_mode = index
		mode_button.icon = _get_mode_icon(resource_editor.metadata_script.sync_mode)
	
	func _get_mode_icon(index: int) -> Texture2D:
		return [
			RESOURCE_OVERRIDE_ICON,
			SYNC_RESOURCE_PROCESS_ICON,
			SYNC_RESOURCE_PHYSICS_ICON
		][index]

	func _update_property() -> void:
		var value : Variant = get_edited_object().get(get_edited_property())
		if value != resource_editor._get_resource().value:
			# not sure why update_property doesn't get called but _update_property does?
			resource_editor._update_property()
	
	func _on_deleted(property: String) -> void:
		if property == get_edited_property():
			resource_editor.remove_override()
	
	func _set_bottom_editor(node: Node):
		if node:
			set_bottom_editor(resource_editor)
		else:
			set_bottom_editor(null)