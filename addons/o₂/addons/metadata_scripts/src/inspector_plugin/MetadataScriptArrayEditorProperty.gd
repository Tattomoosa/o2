@tool
extends O2.EditorExtensions.EditorPropertyCustomArray

const METADATA_SCRIPTS_ICON = preload("uid://cm3wwdg8y3x7m")
var metadata_scripts : Array[MetadataScript]

func _ready() -> void:
	metadata_scripts = MetadataScript.get_metadata_scripts(get_edited_object())
	array = metadata_scripts
	label = "Metadata Scripts"
	super()

func _get_editor_property(index: int) -> EditorProperty:
	var property := {
		&"name": "md_script",
		&"class_name": "",
		&"type": TYPE_OBJECT,
		&"hint": PROPERTY_HINT_RESOURCE_TYPE,
		&"hint_string": "MetadataScript",
		&"usage": 6,
	}
	var script := metadata_scripts[index]
	property.name = str(index)
	var ep := inspector_plugin.instantiate_property_editor(fake_resource_holder, property, true)
	var resource_editor : EditorResourcePicker = H.Nodes.get_descendents_with_type(ep, EditorResourcePicker)[0]
	resource_editor.edited_resource = script
	ep.update_property()
	return ep

func _get_add_button() -> Control:
	var hbox := HBoxContainer.new()
	var object := get_edited_object()
	hbox.add_child(inspector_plugin.create_metadata_script_popup_button(object))
	hbox.add_child(inspector_plugin.create_metadata_script_extend_button())
	return hbox

func _remove(row: ArrayItem) -> void:
	var object := get_edited_object()
	var index := row.get_index()
	var md_script := metadata_scripts[index]
	md_script.detach()
	metadata_scripts.remove_at(index)
	if metadata_scripts.is_empty():
		object.remove_meta(get_edited_property())
	object.notify_property_list_changed()

func _delete_all() -> void:
	for s in metadata_scripts:
		s.detach()
	var object := get_edited_object()
	object.remove_meta(get_edited_property())
	object.notify_property_list_changed()
