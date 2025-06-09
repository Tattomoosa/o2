@tool
extends EditorPlugin

const Controls := O2.Helpers.Controls
const Nodes := O2.Helpers.Nodes
const Plugins := O2.Helpers.Editor.Plugins
const Signals := O2.Helpers.Signals
const Settings := O2.Helpers.Settings
const GDSCRIPT_ICON := preload("uid://dmf2kpb2tkkab")
const VIEWPORT_SETTINGS_ICON := preload("uid://dgmit4iptr022")
const PLUGIN_SETTINGS_ICON := preload("uid://obguu32af2v")

const SHOW_WINDOW_BUTTON_SETTING := "window_mode_menu/enable"
const SHOW_WINDOW_BUTTON_TEXT_SETTING := "window_mode_menu/show_button_text"
const SHOW_PLUGIN_BUTTON_SETTING := "plugin_menu/enable"
const SHOW_PLUGIN_BUTTON_TEXT_SETTING := "plugin_menu/show_button_text"
const PLUGIN_MENU_DISABLE_QUICK_SETTING := "plugin_menu/disable_quick_settings"

var button_parent : Control
var dialog : Window
var plugin_enable_strings := PackedStringArray()

func _enable_plugin() -> void:
	pass

func _enter_tree() -> void:
	_get_or_add_setting(SHOW_WINDOW_BUTTON_SETTING, true)
	_get_or_add_setting(SHOW_WINDOW_BUTTON_TEXT_SETTING, true)
	_get_or_add_setting(SHOW_PLUGIN_BUTTON_SETTING, true)
	_get_or_add_setting(SHOW_PLUGIN_BUTTON_TEXT_SETTING, false)
	_get_or_add_setting(PLUGIN_MENU_DISABLE_QUICK_SETTING, true)
	ProjectSettings.save()
	_create_control()
	add_control_to_container(EditorPlugin.CONTAINER_TOOLBAR, button_parent)

	var hbox := Nodes.get_previous_sibling(button_parent)
	button_parent.reparent(hbox)
	Nodes.move_relative(button_parent, -1)

func _exit_tree() -> void:
	if button_parent and is_instance_valid(button_parent):
		button_parent.queue_free()

func _get_or_add_setting(setting: String, default_value: Variant) -> Variant:
	var plugin_config_prefix := Plugins.get_plugin_config_category(get_script().resource_path)
	return Settings.get_or_add(plugin_config_prefix.path_join(setting), default_value)

func _get_setting(setting: String) -> Variant:
	var plugin_config_prefix := Plugins.get_plugin_config_category(get_script().resource_path)
	return ProjectSettings.get_setting(plugin_config_prefix.path_join(setting))

func _create_control() -> void:
	button_parent = PanelContainer.new()
	var hbox := HBoxContainer.new()

	if _get_setting(SHOW_WINDOW_BUTTON_SETTING):
		var viewport_button := Controls.icon_menu_button(VIEWPORT_SETTINGS_ICON, false)
		viewport_button.tooltip_text = "Change the gameplay window mode"
		_create_viewport_popup(viewport_button)
		hbox.add_child(viewport_button)

	if _get_setting(SHOW_PLUGIN_BUTTON_SETTING):
		var plugin_button := Controls.icon_menu_button(PLUGIN_SETTINGS_ICON, false)
		plugin_button.tooltip_text = "Enable/disable EditorPlugins"
		_create_plugin_popup(plugin_button)
		hbox.add_child(plugin_button)

	button_parent.add_child(hbox)

func _create_viewport_popup(viewport_button: MenuButton) -> void:
	var popup := viewport_button.get_popup()
	var names := ["Windowed", "Minimized", "Maximized", "Fullscreen", "Exclusive Fullscreen"]
	popup.clear()
	popup.add_radio_check_item(names[0], DisplayServer.WindowMode.WINDOW_MODE_WINDOWED)
	popup.add_radio_check_item(names[1], DisplayServer.WindowMode.WINDOW_MODE_MINIMIZED)
	popup.add_radio_check_item(names[2], DisplayServer.WindowMode.WINDOW_MODE_MAXIMIZED)
	popup.add_radio_check_item(names[3], DisplayServer.WindowMode.WINDOW_MODE_FULLSCREEN)
	popup.add_radio_check_item(names[4], DisplayServer.WindowMode.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	var setting_string := "display/window/size/mode"
	var value : int = ProjectSettings.get_setting(setting_string)
	popup.set_item_checked(value, true)
	# var plugin_config_prefix := Plugins.get_plugin_config_category(get_script().resource_path)

	if _get_setting(SHOW_WINDOW_BUTTON_TEXT_SETTING):
		viewport_button.text = names[value]
	else:
		viewport_button.text = ""

	Signals.connect_if_not_connected(popup.about_to_popup, _create_viewport_popup.bind(viewport_button))
	Signals.connect_if_not_connected(
		popup.index_pressed,
		func(index):
			ProjectSettings.set_setting(setting_string, index)
			viewport_button.text = names[index]
	)

func _create_plugin_popup(plugin_button: MenuButton) -> void:
	var popup := plugin_button.get_popup()
	popup.clear()
	popup.hide_on_checkable_item_selection = false
	plugin_enable_strings.clear()
	var plugin_paths := Plugins.get_all_plugin_paths()

	if _get_setting(SHOW_PLUGIN_BUTTON_TEXT_SETTING):
		plugin_button.text = "Plugins"

	# for path in plugin_paths:
	# 	if path.get_file() == "quick_settings":
	# 		plugin_paths.erase(path)
	# 		break

	for i in plugin_paths.size():
		var plugin_path := plugin_paths[i]
		var plugin_enable_string := Plugins.get_plugin_enable_string_from_path(plugin_path)
		var icon := Plugins.get_plugin_icon(plugin_path)
		var display_name := plugin_enable_string.get_file()
		display_name = O2.Helpers.Strings.to_title_cased_spaced(display_name)
		if !icon:
			icon = GDSCRIPT_ICON
		plugin_enable_strings.push_back(plugin_enable_string)
		popup.add_icon_check_item(icon, display_name)
		popup.set_item_indent(i, plugin_enable_string.count("/") * O2.Helpers.Editor.Settings.scale)
		popup.set_item_checked(i, EditorInterface.is_plugin_enabled(plugin_enable_string))
		Signals.connect_if_not_connected(popup.about_to_popup, _create_plugin_popup.bind(plugin_button))
		Signals.connect_if_not_connected(popup.index_pressed, _set_plugin_enabled.bind(popup))

func _set_plugin_enabled(index: int, popup: PopupMenu) -> void:
	var enable_string := plugin_enable_strings[index]
	EditorInterface.set_plugin_enabled(
		enable_string,
		!EditorInterface.is_plugin_enabled(enable_string)
	)
	popup.set_item_checked(index, EditorInterface.is_plugin_enabled(enable_string)
)


