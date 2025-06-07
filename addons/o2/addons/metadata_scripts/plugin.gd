@tool
extends EditorPlugin

const METADATA_SCRIPTS_PROPERTY := "metadata_scripts"
const MetadataScriptTreeWatcherPlugin := preload("uid://segrgfetays3")

var editor_inspector_plugin := MetadataScriptEditorInspectorPlugin.new()

func _enable_plugin() -> void:
	print("enable metadata_scripts")
	# Add autoloads here.
	pass


func _disable_plugin() -> void:
	print("disable metadata_scripts")
	# Remove autoloads here.
	pass

func _enter_tree() -> void:
	print("enter_tree metadata_scripts")
	O2.TreeWatcher.register_plugin(MetadataScriptTreeWatcherPlugin.new())
	add_inspector_plugin(editor_inspector_plugin)


func _exit_tree() -> void:
	print("exit_tree metadata_scripts")
	O2.TreeWatcher.unregister_plugin(MetadataScriptTreeWatcherPlugin.new())
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
					metadata_script_class_data.append(class_data)
		
		var vbox := VBoxContainer.new()
		var center := CenterContainer.new()
		var btn := MenuButton.new()

		btn.theme_type_variation = "AddButton"
		btn.text = "Add Metadata Script"
		var popup := btn.get_popup()
		popup.allow_search = true
		popup.id_pressed.connect(_popup_id_pressed.bind(object))
		for i in metadata_script_class_data.size():
			var class_data := metadata_script_class_data[i]
			var display_name : String = class_data.class
			if display_name.begins_with("MetadataScript_"):
				display_name = display_name.replace("MetadataScript_", "")
			if class_data.icon:
				popup.add_icon_item(class_data.icon, display_name, i)
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
		var metadata_script : MetadataScript = load(class_data.path).new()
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
