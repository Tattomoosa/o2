@tool
extends EditorPlugin

const _Scripts := O2.Helpers.Scripts
const TreeWatcher := O2.TreeWatcher
const METADATA_SCRIPTS_PROPERTY := "metadata_scripts"
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
	TreeWatcher.register_plugin(MetadataScriptTreeWatcherPlugin.new())
	add_inspector_plugin(editor_inspector_plugin)

func _exit_tree() -> void:
	TreeWatcher.unregister_plugin(MetadataScriptTreeWatcherPlugin.new())
	remove_inspector_plugin(editor_inspector_plugin)