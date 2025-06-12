@tool
extends H.Editor.InspectorPlugin

var metadata_script_class_data : Array[Dictionary] = []
const METADATA_SCRIPTS_PROPERTY := MetadataScript.METADATA_SCRIPTS_PROPERTY
const METADATA_SCRIPTS_ICON := preload("uid://cm3wwdg8y3x7m")
const MetadataScriptArrayEditorProperty := preload("MetadataScriptArrayEditorProperty.gd")

func _can_handle(object: Object) -> bool:
	return object is Node

func add_metadata_scripts_array(object: Object, custom_delete := false) -> void:
	if MetadataScript.has_metadata_scripts(object):
		var ep := MetadataScriptArrayEditorProperty.new()
		ep.set_object_and_property(object, METADATA_SCRIPTS_PROPERTY)
		ep.inspector_plugin = self
		if false:
			var fc := create_foldable_container("Metadata Scripts")
			fc.add_child(ep)
			add_custom_control(fc)
		ep.name_split_ratio = 0.0
		ep.label = ""
		ep.use_custom_delete_button = custom_delete
		add_heading(METADATA_SCRIPTS_ICON, "Metadata Scripts")
		add_property_editor(METADATA_SCRIPTS_PROPERTY, ep)

func parse_property(_object: Object, _type: Variant.Type, name: String, _hint_type: PropertyHint, _hint_string: String, _usage_flags: int, _wide: bool) -> bool:
	if name == "metadata/" + METADATA_SCRIPTS_PROPERTY:
		return false
	return false

func _parse_begin(object: Object) -> void:
	pass

func _parse_end(object: Object) -> void:
	if MetadataScript.has_metadata_scripts(object):
		add_metadata_scripts_array(object, true)
		return
	metadata_script_class_data = []
	for class_data in ProjectSettings.get_global_class_list():
		if class_data.base == "MetadataScript":
			if !class_data.is_abstract:
				var metadata_script_class : GDScript = load(class_data.path)
				if metadata_script_class.can_attach_to(object):
					metadata_script_class_data.append(class_data)
	
	var btn := create_metadata_script_popup_button(object)
	
	var hbox := HBoxContainer.new()
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_custom_control(hbox)
	var inspector := EditorInterface.get_inspector()
	var add_metadata_button : Button
	var buttons := H.Nodes.get_descendents_with_type(inspector, Button, true)
	for b in buttons:
		if b.text == "Add Metadata":
			add_metadata_button = b
			break
	if add_metadata_button:
		add_metadata_button.reparent(hbox)
	hbox.add_child(btn)

func create_metadata_script_popup_button(object: Object) -> MenuButton:
	var btn := MenuButton.new()
	H.Editor.InspectorPlugin.style_inspector_button(btn, "Add")
	btn.icon = METADATA_SCRIPTS_ICON
	btn.text = "Add Metadata Script"
	btn.alignment = HORIZONTAL_ALIGNMENT_CENTER
	btn.flat = false
	var popup := btn.get_popup()
	popup.allow_search = true
	popup.id_pressed.connect(_popup_id_pressed.bind(object))
	for i in metadata_script_class_data.size():
		var class_data := metadata_script_class_data[i]
		var display_name : String = class_data.class
		if display_name.begins_with("MetadataScript_"):
			display_name = display_name.replace("MetadataScript_", "")
		var icon := Scripts.get_icon(class_data.class)
		if icon:
			popup.add_icon_item(icon, display_name, i)
		else:
			popup.add_item(display_name, i)
	return btn

func _popup_id_pressed(id: int, object: Object) -> void:
	var class_data := metadata_script_class_data[id]
	var metadata_script_class : GDScript = load(class_data.path)
	var metadata_script : MetadataScript = metadata_script_class.new()
	metadata_script.attach_to(object)
	object.notify_property_list_changed()