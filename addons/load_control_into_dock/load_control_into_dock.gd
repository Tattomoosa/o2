@tool
extends EditorPlugin

const LoadControlIntoDockPlugin := preload("load_control_into_dock.gd")
const IconGrabber := preload("uid://bqm5oyuqkkn2r")
const PLUGIN_ICON := preload("uid://d173jdavljnfr")

# Scene Dock
var load_control_from_edited_scene_context_menu_plugin : LoadControlIntoDockContextMenuPlugin
# File Dock
var load_control_from_packed_scene_context_menu_plugin : LoadPackedSceneIntoDockContextMenuPlugin
var icon_grabber : IconGrabber

func _enable_plugin() -> void:
	# Add autoloads here.
	pass

func _disable_plugin() -> void:
	# Remove autoloads here.
	pass

func _enter_tree() -> void:
	icon_grabber = IconGrabber.new()
	load_control_from_edited_scene_context_menu_plugin = LoadControlIntoDockContextMenuPlugin.new(self)
	load_control_from_packed_scene_context_menu_plugin = LoadPackedSceneIntoDockContextMenuPlugin.new(self)
	add_context_menu_plugin(EditorContextMenuPlugin.CONTEXT_SLOT_SCENE_TREE, load_control_from_edited_scene_context_menu_plugin)
	add_context_menu_plugin(EditorContextMenuPlugin.CONTEXT_SLOT_FILESYSTEM, load_control_from_packed_scene_context_menu_plugin)

func _ready() -> void:
	icon_grabber.update_icon_list()

func _exit_tree() -> void:
	remove_context_menu_plugin(load_control_from_edited_scene_context_menu_plugin)
	remove_context_menu_plugin(load_control_from_packed_scene_context_menu_plugin)

# Loads a PackedScene extending Control from the filesystem into a dock
class LoadPackedSceneIntoDockContextMenuPlugin extends LoadControlIntoDockContextMenuPlugin:
	var control_classes := ClassDB.get_inheriters_from_class(&"Control")
	func _popup_menu(paths: PackedStringArray) -> void:
		if paths.size() > 1:
			return
		var path := paths[0]
		if path.get_extension() != "tscn":
			return
		var scene : PackedScene = load(path)
		if scene.get_state().get_node_type(0) not in control_classes:
			return
		_create_menu(_add_scene_to_bottom_panel.bind(scene), _add_scene_to_dock.bind(scene))

	func _add_scene_to_bottom_panel(_files: Array, packed_scene: PackedScene) -> void:
		var control := packed_scene.instantiate()
		var editor_control := package_control(
			control,
			_remove_from_bottom_panel,
			_reload_scene.bind(packed_scene)
		)
		_editor_plugin.add_control_to_bottom_panel(editor_control, control.name)
	
	# func _reload_scene(scene: PackedScene, control_parent: Control) -> void:
	func _reload_scene(control_parent: Control, scene: PackedScene) -> void:
		var control = scene.instantiate()
		var old_control = control_parent.get_child(0)
		control_parent.remove_child(old_control)
		old_control.queue_free()
		control_parent.add_child(control)

	func _add_scene_to_dock(dock_index: int, scene: PackedScene) -> void:
		var control = scene.instantiate()
		var editor_control := package_control(
			control,
			_remove_from_bottom_panel,
			_reload_scene.bind(scene)
		)
		editor_control.name = control.name
		_editor_plugin.add_control_to_dock(dock_index, editor_control)
		_editor_plugin.set_dock_tab_icon(editor_control, _get_icon(control))


# Loads a Control from a scene into a dock
class LoadControlIntoDockContextMenuPlugin extends EditorContextMenuPlugin:
	var _editor_plugin : LoadControlIntoDockPlugin

	func _init(editor_plugin: EditorPlugin) -> void:
		_editor_plugin = editor_plugin

	func _popup_menu(paths: PackedStringArray) -> void:
		var scene_root := EditorInterface.get_edited_scene_root()
		if paths.size() > 1:
			return
		var node := scene_root.get_node(paths[0])
		if node is not Control:
			return
		var add_to_bottom_panel_callback := _add_control_to_bottom_panel
		var add_to_dock_callback := _add_control_to_dock.bind(node)
		_create_menu(add_to_bottom_panel_callback, add_to_dock_callback)
	
	func _create_menu(add_to_bottom_panel_callback: Callable, add_to_dock_callback: Callable) -> void:
		var inspector := EditorInterface.get_inspector()
		var l := inspector.get_theme_icon("ControlAlignLeftWide", &"EditorIcons")
		var r := inspector.get_theme_icon("ControlAlignRightWide", &"EditorIcons")
		# inspector.get_theme_icon("ControlAlignBottomWide", &"EditorIcons")
		var ul := inspector.get_theme_icon("ControlAlignTopLeft", &"EditorIcons")
		var ur := inspector.get_theme_icon("ControlAlignTopRight", &"EditorIcons")
		var bl := inspector.get_theme_icon("ControlAlignBottomLeft", &"EditorIcons")
		var br := inspector.get_theme_icon("ControlAlignBottomRight", &"EditorIcons")

		add_context_menu_item("Add Control To Bottom Panel", add_to_bottom_panel_callback, PLUGIN_ICON)

		var left_submenu_popup := PopupMenu.new()
		left_submenu_popup.add_icon_item(ur, "Left Dock - Upper Right", EditorPlugin.DOCK_SLOT_LEFT_UR)
		left_submenu_popup.add_icon_item(br, "Left Dock - Bottom Right", EditorPlugin.DOCK_SLOT_LEFT_BR)
		left_submenu_popup.add_icon_item(ul, "Left Dock - Upper Left", EditorPlugin.DOCK_SLOT_LEFT_UL)
		left_submenu_popup.add_icon_item(bl, "Left Dock - Bottom Left", EditorPlugin.DOCK_SLOT_LEFT_BL)
		left_submenu_popup.id_pressed.connect(add_to_dock_callback)

		var right_submenu_popup := PopupMenu.new()
		right_submenu_popup.add_icon_item(ul, "Right Dock - Upper Left", EditorPlugin.DOCK_SLOT_RIGHT_UL)
		right_submenu_popup.add_icon_item(bl, "Right Dock - Bottom Left", EditorPlugin.DOCK_SLOT_RIGHT_BL)
		right_submenu_popup.add_icon_item(ur, "Right Dock - Upper Right", EditorPlugin.DOCK_SLOT_RIGHT_UR)
		right_submenu_popup.add_icon_item(br, "Right Dock - Bottom Right", EditorPlugin.DOCK_SLOT_RIGHT_BR)
		right_submenu_popup.id_pressed.connect(add_to_dock_callback)

		add_context_submenu_item("Add Control to Left Dock", left_submenu_popup, l)
		add_context_submenu_item("Add Control to Right Dock", right_submenu_popup, r)
	
	func _add_control_to_dock(dock_index: int, control: Control) -> void:
		var editor_control := package_control(
			control.duplicate(Node.DUPLICATE_USE_INSTANTIATION),
			_remove_from_docks,
			_reload.bind(control)
		)
		editor_control.name = control.name
		_editor_plugin.add_control_to_dock(dock_index, editor_control)
		_editor_plugin.set_dock_tab_icon(editor_control, _get_icon(control))
	
	func _get_icon(control: Control) -> Texture2D:
		var c_name := ""
		var script : Script = control.get_script()
		if script:
			c_name = script.get_global_name()
		if !c_name:
			c_name = control.get_class()
		return _editor_plugin.icon_grabber.get_class_icon(c_name)

	func _add_control_to_bottom_panel(controls: Array) -> void:
		var editor_control := package_control(
			controls[0].duplicate(Node.DUPLICATE_USE_INSTANTIATION),
			_remove_from_bottom_panel,
			_reload.bind(controls[0])
		)
		_editor_plugin.add_control_to_bottom_panel(editor_control, controls[0].name)
	
	func _remove_from_bottom_panel(control: Control) -> void:
		_editor_plugin.remove_control_from_bottom_panel(control)
		control.queue_free()

	func _remove_from_docks(control: Control) -> void:
		_editor_plugin.remove_control_from_docks(control)
		control.queue_free()
	
	# func _reload(control: Control, control_parent: Control) -> void:
	func _reload(control_parent: Control, control: Control) -> void:
		var new_control := control.duplicate(Node.DUPLICATE_USE_INSTANTIATION)
		var old_control := control_parent.get_child(0)
		control_parent.remove_child(old_control)
		old_control.queue_free()
		control_parent.add_child(new_control)
	
	func package_control(control: Control, remove_callback: Callable, reload_callback: Callable) -> Control:
		var control_parent := MarginContainer.new()
		var c : Control = control.duplicate(Node.DUPLICATE_USE_INSTANTIATION)
		var vbox := VBoxContainer.new()
		vbox.add_theme_constant_override("separation", 0)
		vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
		vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var heading := PanelContainer.new()
		heading.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		if true:
			var hbox := HBoxContainer.new()
			hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			if true: # Reload
				var reload_button := Button.new()
				# reload_button.tooltip = "Reload"
				reload_button.icon = EditorInterface.get_inspector().get_theme_icon("Reload", &"EditorIcons")
				reload_button.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
				reload_button.pressed.connect(reload_callback.bind(control_parent))
				hbox.add_child(reload_button)
			if true: # Inspect Button
				var inspect_button := Button.new()
				inspect_button.icon = EditorInterface.get_inspector().get_theme_icon("FileList", &"EditorIcons")
				# inspect_button.tooltip = "Edit in Inspector"
				# inspect_button.text = "Inspect"
				inspect_button.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
				inspect_button.pressed.connect(func(): EditorInterface.get_inspector().edit(control_parent.get_child(0)))
				hbox.add_child(inspect_button)
			# if true: # Select Button
			# 	var select_button := Button.new()
			# 	select_button.icon = EditorInterface.get_inspector().get_theme_icon("PackedScene", &"EditorIcons")
			# 	select_button.text = "Select in Scene"
			# 	select_button.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
			# 	select_button.pressed.connect(
			# 		func():
			# 			EditorInterface.edit_node(control)
			# 			)
			# 	hbox.add_child(select_button)
			if true: # Spacer
				var spacer := Control.new()
				spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				hbox.add_child(spacer)
			if true: # Remove
				var remove_button := Button.new()
				# remove_button.tooltip = "Remove Dock"
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