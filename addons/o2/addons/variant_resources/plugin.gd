@tool
extends EditorPlugin

const PrimitiveResourceInspectorPlugin := preload("uid://b6p1blka8mr6p")

var inspector_plugin := PrimitiveResourceInspectorPlugin.new()

func _enable_plugin() -> void:
	pass

func _disable_plugin() -> void:
	pass

func _enter_tree() -> void:
	add_inspector_plugin(inspector_plugin)

func _exit_tree() -> void:
	remove_inspector_plugin(inspector_plugin)
