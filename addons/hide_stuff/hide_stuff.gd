@tool
extends EditorPlugin

var interface_elements : InterfaceElements

var hider_classes : Array[Script] = [
	HideMainScreenButtonNames,
	HideRendererMenuButton,
	HideDockTabs,
]
var hiders : Array[HideSomething] = []

func _ready() -> void:
	name = "HideStuff"
	interface_elements = InterfaceElements.new()
	add_child(interface_elements, true)
	await get_tree().process_frame
	var command_palette := EditorInterface.get_command_palette()
	for hider_class in hider_classes:
		var hider : HideSomething = hider_class.new(interface_elements)
		var hide_command := "%s_hide" % hider.get_command_name()
		var show_command := "%s_show" % hider.get_command_name()
		command_palette.add_command(hide_command.capitalize(), "hide_stuff".path_join(hide_command), hider.hide_it) 
		command_palette.add_command(show_command.capitalize(), "hide_stuff".path_join(show_command), hider.show_it) 
		hiders.push_back(hider)
		add_child(hider)

func _exit_tree() -> void:
	var command_palette := EditorInterface.get_command_palette()
	for child in get_children():
		if child is HideSomething:
			var hider : HideSomething = child
			var hide_command := "%s_hide" % hider.get_command_name()
			var show_command := "%s_show" % hider.get_command_name()
			command_palette.remove_command("hide_stuff".path_join(hide_command))
			command_palette.remove_command("hide_stuff".path_join(show_command))
		child.queue_free()
	request_ready()

class InterfaceElements extends EditorPlugin:
	var _custom_containers : Dictionary[CustomControlContainer, Control] = {}
	var _docks : Dictionary[DockSlot, Control] = {}

	func _enter_tree() -> void:
		_get_custom_containers()
		_get_docks()
	
	func _get_custom_containers() -> void:
		var c := Control.new()
		for key in [CONTAINER_TOOLBAR, CONTAINER_SPATIAL_EDITOR_MENU, CONTAINER_SPATIAL_EDITOR_SIDE_LEFT, CONTAINER_SPATIAL_EDITOR_SIDE_RIGHT, CONTAINER_SPATIAL_EDITOR_BOTTOM, CONTAINER_CANVAS_EDITOR_MENU, CONTAINER_CANVAS_EDITOR_SIDE_LEFT, CONTAINER_CANVAS_EDITOR_SIDE_RIGHT, CONTAINER_CANVAS_EDITOR_BOTTOM, CONTAINER_INSPECTOR_BOTTOM, CONTAINER_PROJECT_SETTING_TAB_LEFT, CONTAINER_PROJECT_SETTING_TAB_RIGHT]:
			add_control_to_container(key, c)
			_custom_containers[key] = c.get_parent()
			remove_control_from_container(key, c)
		c.queue_free()

	func _get_docks() -> void:
		var dummy_control := Control.new()
		for slot in DOCK_SLOT_MAX:
			add_control_to_dock(slot, dummy_control)
			_docks[slot] = dummy_control.get_parent()
			remove_control_from_docks(dummy_control)
		dummy_control.queue_free()
	
	func get_toolbar() -> HBoxContainer:
		return _custom_containers[CONTAINER_TOOLBAR]
	
	func get_main_screen_buttons() -> HBoxContainer:
		return _custom_containers[CONTAINER_TOOLBAR].get_node("EditorMainScreenButtons")
	
	func get_docks() -> Array[Control]:
		return _docks.values()

class HideSomething extends Node:
	var _interface_elements : InterfaceElements
	
	func hide_it() -> void:
		pass

	func show_it() -> void:
		pass

	func get_command_name() -> String:
		return "something"
	
	func _init(interface_elements: InterfaceElements) -> void:
		_interface_elements = interface_elements

	func _enter_tree() -> void:
		hide_it()

	func _exit_tree() -> void:
		show_it()

class HideRendererMenuButton extends HideSomething:
	var _renderer_button : Button

	func get_command_name() -> String: return "renderer_menu_button"

	func hide_it() -> void:
		var toolbar := _interface_elements.get_toolbar()
		for i in range(toolbar.get_child_count() -1, -1, -1):
			var c := toolbar.get_child(i)
			if c is HBoxContainer:
				for child in c.get_children():
					if child is not Button:
						continue
					if child.text in ["Forward+", "Mobile", "Compatibility"]:
						_renderer_button = child
						_renderer_button.hide()

	func show_it() -> void:
		_renderer_button.show()

# Seems it's only possible to hide the names, that's ok
class HideMainScreenButtonNames extends HideSomething:

	func get_command_name() -> String: return "main_screen_button_names"

	func hide_it() -> void:
		var main_screen_buttons := _interface_elements.get_main_screen_buttons()
		for c in main_screen_buttons.get_children():
			c.text = ""

	func show_it() -> void:
		var main_screen_buttons := _interface_elements.get_main_screen_buttons()
		for c in main_screen_buttons.get_children():
			c.text = c.name
			c.expand_icon = false

class HideDockTabs extends HideSomething:
	func get_command_name() -> String: return "dock_tabs"

	func hide_it() -> void:
		for dock in _interface_elements.get_docks():
			dock.tabs_visible = false

	func show_it() -> void:
		for dock in _interface_elements.get_docks():
			dock.tabs_visible = true
