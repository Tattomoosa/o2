@tool
extends EditorPlugin

const tools_dock_scene := preload("uid://bagj2x3qnhgkh")
const plugin_icon := preload("uid://d0mcyi8ajfh02")

var tools_dock : Control
var dock_popup : Popup
var add_to_bottom_button : Button

func _enable_plugin() -> void:
	# Add autoloads here.
	pass

func _disable_plugin() -> void:
	# Remove autoloads here.
	pass

func _enter_tree() -> void:
	name = "PluginDevTools"
	tools_dock = tools_dock_scene.instantiate()
	add_control_to_dock(DOCK_SLOT_RIGHT_BL, tools_dock)
	set_dock_tab_icon(tools_dock, plugin_icon)
	_add_bottom_panel_button_to_popup()

func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	remove_control_from_docks(tools_dock)
	tools_dock.queue_free()

func _add_bottom_panel_button_to_popup() -> void:
	var tc : TabContainer = tools_dock.get_parent()
	print(tc)
	var popup := tc.get_popup()
	print(popup)
	popup.print_tree_pretty()
	var vbox := popup.get_child(1, true)
	for child in vbox.get_children(true):
		if child is Button:
			print(child.text)