@tool
extends O2.Helpers.Editor.InspectorPlugin

var metadata_script_class_data : Array[Dictionary] = []
const Scripts := O2.Helpers.Scripts
const METADATA_SCRIPTS_PROPERTY := MetadataScript.METADATA_SCRIPTS_PROPERTY

func _can_handle(object: Object) -> bool:
	return object is Node

func _parse_property(object: Object, type: Variant.Type, name: String, hint_type: PropertyHint, hint_string: String, usage_flags: int, wide: bool) -> bool:
	prints(object, name)
	if name.begins_with("metadata"):
		print(name)
	return false

func _parse_end(object: Object) -> void:
	metadata_script_class_data = []
	for class_data in ProjectSettings.get_global_class_list():
		if class_data.base == "MetadataScript":
			if !class_data.is_abstract:
				var metadata_script_class : GDScript = load(class_data.path)
				if metadata_script_class.can_attach_to(object):
					metadata_script_class_data.append(class_data)
	
	# var center := CenterContainer.new()
	var btn := MenuButton.new()

	O2.Helpers.Editor.InspectorPlugin.style_inspector_button(btn, "Add")
	btn.icon = load("uid://cm3wwdg8y3x7m")
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
	
	var hbox := HBoxContainer.new()
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_custom_control(hbox)
	var inspector := EditorInterface.get_inspector()
	# inspector.print_tree_pretty()
	var add_metadata_button : Button
	var buttons := O2.Helpers.Nodes.get_descendents_with_type(inspector, Button, true)
	for b in buttons:
		if b.text == "Add Metadata":
			add_metadata_button = b
			break
	if add_metadata_button:
		add_metadata_button.reparent(hbox)
	hbox.add_child(btn)

func _popup_id_pressed(id: int, object: Object) -> void:
	var class_data := metadata_script_class_data[id]
	var metadata_script_class : GDScript = load(class_data.path)
	var metadata_script : MetadataScript = metadata_script_class.new()
	if object.has_meta(METADATA_SCRIPTS_PROPERTY):
		var scripts : Array[MetadataScript] = object.get_meta(METADATA_SCRIPTS_PROPERTY)
		scripts.append(metadata_script)
	else:
		object.set_meta(METADATA_SCRIPTS_PROPERTY, [metadata_script] as Array[MetadataScript])
	metadata_script.tree_entered(object)
	object.notify_property_list_changed()

func _remove(script: MetadataScript, object: Object) -> void:
	var scripts : Array[MetadataScript] = object.get_meta(METADATA_SCRIPTS_PROPERTY)
	scripts.erase(script)
	object.notify_property_list_changed()
