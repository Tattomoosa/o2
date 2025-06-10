@tool
extends EditorPlugin

const _Scripts := O2.Helpers.Scripts
const TreeWatcher := O2.TreeWatcher
const METADATA_SCRIPTS_PROPERTY := "metadata_scripts"
const MetadataScriptTreeWatcherPlugin := preload("uid://segrgfetays3")

var editor_inspector_plugin := MetadataScriptEditorInspectorPlugin.new()

func _enable_plugin() -> void:
	# Add autoloads here.
	pass


func _disable_plugin() -> void:
	# Remove autoloads here.
	pass

func _enter_tree() -> void:
	TreeWatcher.register_plugin(MetadataScriptTreeWatcherPlugin.new())
	add_inspector_plugin(editor_inspector_plugin)

func _exit_tree() -> void:
	TreeWatcher.unregister_plugin(MetadataScriptTreeWatcherPlugin.new())
	remove_inspector_plugin(editor_inspector_plugin)

class MetadataScriptEditorInspectorPlugin extends EditorInspectorPlugin:
	var metadata_script_class_data : Array[Dictionary] = []

	func _can_handle(object: Object) -> bool:
		return object is Node

	func _parse_end(object: Object) -> void:
		metadata_script_class_data = []
		for class_data in ProjectSettings.get_global_class_list():
			if class_data.base == "MetadataScript":
				if !class_data.is_abstract:
					var metadata_script_class : GDScript = load(class_data.path)
					if metadata_script_class.can_attach_to(object):
						metadata_script_class_data.append(class_data)
		
		var vbox := VBoxContainer.new()
		var center := CenterContainer.new()
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
			var icon := _Scripts.get_icon(class_data.class)
			if icon:
				popup.add_icon_item(icon, display_name, i)
			else:
				popup.add_item(display_name, i)
		center.add_child(btn)
		vbox.add_child(center)
		# lol
		var spacing_control := Control.new()
		spacing_control.custom_minimum_size.y = 800
		vbox.add_child(spacing_control)
		add_custom_control(vbox)
	
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
