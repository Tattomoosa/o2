@tool
extends EditorPlugin

const tools_dock_scene := preload("uid://bagj2x3qnhgkh")
const plugin_icon := preload("uid://d0mcyi8ajfh02")

var tools_dock : Control

func _enable_plugin() -> void:
	# Add autoloads here.
	pass


func _disable_plugin() -> void:
	# Remove autoloads here.
	pass


func _enter_tree() -> void:
	tools_dock = tools_dock_scene.instantiate()
	# Initialization of the plugin goes here.
	add_control_to_dock(DOCK_SLOT_RIGHT_BL, tools_dock)
	set_dock_tab_icon(tools_dock, plugin_icon)


func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	remove_control_from_docks(tools_dock)
