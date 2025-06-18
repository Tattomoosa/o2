@tool
extends EditorPlugin

const TreeWatcher := O2.TreeWatcher
const MetadataScriptTreeWatcherPlugin := preload("uid://segrgfetays3")
const MetadataScriptEditorInspectorPlugin := preload("uid://oak2yxxjxyjt")

var editor_inspector_plugin := MetadataScriptEditorInspectorPlugin.new()

func _enable_plugin() -> void:
	# Add autoloads here.
	pass

func _disable_plugin() -> void:
	# Remove autoloads here.
	pass

func _enter_tree() -> void:
	name = "Metadata Scripts"
	TreeWatcher.register_plugin(MetadataScriptTreeWatcherPlugin.new())
	add_inspector_plugin(editor_inspector_plugin)

func _exit_tree() -> void:
	TreeWatcher.unregister_plugin(MetadataScriptTreeWatcherPlugin.new())
	remove_inspector_plugin(editor_inspector_plugin)