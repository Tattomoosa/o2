@tool
extends O2.Helpers.Editor.InspectorPlugin

const H := O2.Helpers
const VariantResourceInspector := preload("VariantResourceInspector.gd")
const TYPE_MAP := VariantResourceInspector.TYPE_MAP
const RESOURCE_OVERRIDE_ICON := preload("uid://cmhsyh2bllenw")
const SYNC_RESOURCE_PROCESS_ICON := preload("uid://bfqtnpcim5od6")
const SYNC_RESOURCE_PHYSICS_ICON := preload("uid://ciejl2enkdkyp")

func parse_property(object: Object, type: Variant.Type, name: String, _hint_type: PropertyHint, _hint_string: String, _usage_flags: int, _wide: bool) -> bool:
	if type not in TYPE_MAP:
		return false
	if !_get_override_script(object, name):
		_add_override_context_menu_item(object, name, type)
		return false
	return false

func can_patch(ep: EditorProperty) -> bool:
	if ep is OverriddenEditorProperty:
		return false
	var object := ep.get_edited_object()
	var property_name := ep.get_edited_property()
	var has_override := _get_override_script(object, property_name) != null
	if has_override:
		if ep.get_script():
			push_warning("Can't override, EditorProperty for %s.%s already has a script attached!" % [ep.get_edited_object(), ep.get_edited_property()])
			return false
		return true
	return false

func patch(ep: EditorProperty) -> EditorProperty:
	print("Override override_script_property inspector patching: ", ep)
	var object := ep.get_edited_object()
	var property_name := ep.get_edited_property()
	var object_property := O2.Helpers.PropertyInfo.get_property(object, property_name)
	var override_script := _get_override_script(object, property_name)
	if !override_script:
		return ep
	ep.set_script(OverriddenEditorProperty)
	var overridden_ep := ep as OverriddenEditorProperty
	var override_script_property := PropertyInfo.get_property(override_script, "resource")
	override_script_property.hint_string = TYPE_MAP[object_property.type]
	var resource_editor := instantiate_patched_property_editor(override_script, override_script_property, VariantResourceOverrideEditorProperty)
	resource_editor.inspector_plugin = self
	resource_editor.label = property_name.to_pascal_case()
	resource_editor.metadata_script = override_script
	resource_editor.original_object = object
	resource_editor.property_definition = object_property
	overridden_ep.resource_editor = resource_editor
	overridden_ep.patch()
	return overridden_ep

func _get_override_script(object: Object, property_name: String) -> MetadataScript_SyncVariantResource:
	var m_scripts := MetadataScript.get_metadata_scripts(object)
	for ms in m_scripts:
		if ms is MetadataScript_SyncVariantResource and ms.property_name == property_name:
			return ms
	return null

func _add_override_context_menu_item(object: Object, property_name: String, type: Variant.Type) -> void:
	add_context_menu_item(
		object,
		property_name,
		"Override Property (%s)" % TYPE_MAP[type],
		_add_resource_override.bindv(
			[object, property_name]
		).unbind(1),
	)

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
			vr_editor.inspector_plugin = self
			vr_editor.label = property_name.to_pascal_case()
			vr_editor.metadata_script = s
			vr_editor.original_object = object
			vr_editor.property_definition = object_property
			var overridden_editor_property := OverriddenEditorProperty.new()
			overridden_editor_property.resource_editor = vr_editor
			return overridden_editor_property
	return null

# static func get_resource_override_metadata_script(object: Object, property_name: String) -> MetadataScript_SyncVariantResource:
# 	var metadata_scripts : Array = object.get_meta("metadata_scripts")
# 	for md_script in metadata_scripts:
# 		if !md_script is MetadataScript_SyncVariantResource:
# 			continue
# 		var s := md_script as MetadataScript_SyncVariantResource
# 		if s.property_name != property_name:
# 			continue
# 		return s
# 	return null


class VariantResourceOverrideEditorProperty extends VariantResourceInspector.VariantResourceEditorProperty:
	var original_object : Object
	var metadata_script : Object

	# func _init() -> void:
	# 	print("OVERRIDE INIT!")
	# 	if is_inside_tree():
	# 		print("IS IN TREE")
	# 	if is_node_ready():
	# 		print("NODE IS READY!")
	# 		_ready()
	# 	print("NODE NOT READY!")
	# 	ready.connect(_ready)

	func _ready() -> void:
		print("OVERRIDE READY!")
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

		return inspector_plugin.instantiate_property_editor(
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

	func patch() -> void:
		for child in get_children():
			child.queue_free()
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
