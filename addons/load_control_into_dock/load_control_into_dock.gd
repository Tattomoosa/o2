@tool
extends EditorPlugin

const LoadControlIntoDockPlugin := preload("load_control_into_dock.gd")
const IconGrabber := preload("uid://bqm5oyuqkkn2r")
const PLUGIN_ICON := preload("uid://d173jdavljnfr")

var load_control_context_menu_plugin : LoadControlIntoDockContextMenuPlugin
var icon_grabber : IconGrabber

func _enable_plugin() -> void:
	# Add autoloads here.
	pass


func _disable_plugin() -> void:
	# Remove autoloads here.
	pass

func _enter_tree() -> void:
	icon_grabber = IconGrabber.new()
	load_control_context_menu_plugin = LoadControlIntoDockContextMenuPlugin.new(self)
	add_context_menu_plugin(EditorContextMenuPlugin.CONTEXT_SLOT_SCENE_TREE, load_control_context_menu_plugin)

func _ready() -> void:
	icon_grabber.update_icon_list()

func _exit_tree() -> void:
	remove_context_menu_plugin(load_control_context_menu_plugin)

class LoadControlIntoDockContextMenuPlugin extends EditorContextMenuPlugin:
	var _editor_plugin : LoadControlIntoDockPlugin
	# var _added_bottom_panel_controls : Array[Control]
	# var _added_dock_controls : Array[Control]

	func _init(editor_plugin: EditorPlugin) -> void:
		_editor_plugin = editor_plugin

	func _popup_menu(paths: PackedStringArray) -> void:
		print(paths)
		var scene_root := EditorInterface.get_edited_scene_root()
		if paths.size() > 1:
			return
		# var node := scene_root if paths[0] == "." else scene_root.find_child(paths[0])
		var node := scene_root.get_node(paths[0])
		if node is not Control:
			return
		add_context_menu_item("Add To Bottom Panel", _add_control_to_bottom_panel, PLUGIN_ICON)
		var submenu_popup := PopupMenu.new()
		submenu_popup.add_item("Add to Left Dock - Upper Left", EditorPlugin.DOCK_SLOT_LEFT_UL)
		submenu_popup.add_item("Add to Left Dock - Upper Right", EditorPlugin.DOCK_SLOT_LEFT_UR)
		submenu_popup.add_item("Add to Left Dock - Bottom Left", EditorPlugin.DOCK_SLOT_LEFT_BL)
		submenu_popup.add_item("Add to Left Dock - Bottom Right", EditorPlugin.DOCK_SLOT_LEFT_BR)
		submenu_popup.add_item("Add to Right Dock - Upper Left", EditorPlugin.DOCK_SLOT_RIGHT_UL)
		submenu_popup.add_item("Add to Right Dock - Upper Right", EditorPlugin.DOCK_SLOT_RIGHT_UR)
		submenu_popup.add_item("Add to Right Dock - Bottom Left", EditorPlugin.DOCK_SLOT_RIGHT_BL)
		submenu_popup.add_item("Add to Right Dock - Bottom Right", EditorPlugin.DOCK_SLOT_RIGHT_BR)
		submenu_popup.id_pressed.connect(_add_control_to_dock.bind(node))
		add_context_submenu_item("Add to Dock", submenu_popup, PLUGIN_ICON)
	
	func _add_control_to_dock(dock_index: int, control: Control) -> void:
		var editor_control := _package_control(control, _editor_plugin.remove_control_from_docks)
		editor_control.name = control.name
		_editor_plugin.add_control_to_dock(dock_index, editor_control)

		var c_name := ""
		var script : Script = control.get_script()
		if script:
			c_name = script.get_global_name()
		if !c_name:
			c_name = control.get_class()
		var icon : Texture2D = _editor_plugin.icon_grabber.get_class_icon(c_name)
		_editor_plugin.set_dock_tab_icon(editor_control, icon)

	func _add_control_to_bottom_panel(controls: Array) -> void:
		var editor_control := _package_control(controls[0], _editor_plugin.remove_control_from_bottom_panel)
		_editor_plugin.add_control_to_bottom_panel(editor_control, controls[0].name)
	
	func _package_control(control: Control, remove_callback: Callable) -> Control:
		var control_parent := MarginContainer.new()
		var c : Control = control.duplicate()
		var vbox := VBoxContainer.new()
		vbox.add_theme_constant_override("separation", 0)
		vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
		vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var heading := PanelContainer.new()
		heading.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		if true:
			var hbox := HBoxContainer.new()
			hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			if true:
				var inspect_button := Button.new()
				inspect_button.icon = EditorInterface.get_inspector().get_theme_icon("FileList", &"EditorIcons")
				inspect_button.text = "Inspect"
				inspect_button.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
				inspect_button.pressed.connect(func(): EditorInterface.get_inspector().edit(control_parent.get_child(0)))
				hbox.add_child(inspect_button)
			if true:
				var select_button := Button.new()
				select_button.icon = EditorInterface.get_inspector().get_theme_icon("PackedScene", &"EditorIcons")
				select_button.text = "Select in Scene"
				select_button.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
				select_button.pressed.connect(
					func():
						EditorInterface.edit_node(control)
						)
				hbox.add_child(select_button)
			if true:
				var spacer := Control.new()
				spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				hbox.add_child(spacer)
			if true:
				var reload_button := Button.new()
				reload_button.icon = EditorInterface.get_inspector().get_theme_icon("Reload", &"EditorIcons")
				reload_button.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
				reload_button.pressed.connect(func(): control_parent.get_child(0).replace_by(control.duplicate()))
				hbox.add_child(reload_button)
			if true:
				var remove_button := Button.new()
				remove_button.icon = EditorInterface.get_inspector().get_theme_icon("Close", &"EditorIcons")
				remove_button.size_flags_horizontal = Control.SIZE_SHRINK_END
				remove_button.pressed.connect(remove_callback.bind(vbox))
				hbox.add_child(remove_button)
			heading.add_child(hbox)
		vbox.add_child(heading)

		control_parent.add_theme_constant_override("margin_left", 0)
		control_parent.add_theme_constant_override("margin_right", 0)
		control_parent.add_theme_constant_override("margin_top", 0)
		control_parent.add_theme_constant_override("margin_bottom", 0)
		control_parent.size_flags_vertical = Control.SIZE_EXPAND_FILL
		control_parent.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		vbox.add_child(control_parent)

		c.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		c.size_flags_vertical = Control.SIZE_EXPAND_FILL
		control_parent.add_child(c)
		return vbox
