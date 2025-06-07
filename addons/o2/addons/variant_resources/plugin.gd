@tool
extends EditorPlugin

const PrimitiveResourceInspectorPlugin := preload("uid://b6p1blka8mr6p")

var inspector_plugin := PrimitiveResourceInspectorPlugin.new()

func _enable_plugin() -> void:
	print("enable variant_resources")
	# Add autoloads here.
	pass


func _disable_plugin() -> void:
	print("disable variant_resources")
	# Remove autoloads here.
	pass


func _enter_tree() -> void:
	print("enter_tree variant_resources")
	# Initialization of the plugin goes here.
	add_inspector_plugin(inspector_plugin)
	pass


func _exit_tree() -> void:
	print("exit_tree variant_resources")
	# Clean-up of the plugin goes here.
	remove_inspector_plugin(inspector_plugin)
	pass
