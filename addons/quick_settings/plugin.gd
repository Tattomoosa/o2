@tool
extends EditorPlugin

const Plugins := H.Editor.Plugins

const GDSCRIPT_ICON := preload("uid://dmf2kpb2tkkab")
const VIEWPORT_SETTINGS_ICON := preload("uid://dgmit4iptr022")
const PLUGIN_SETTINGS_ICON := preload("uid://obguu32af2v")
const INTERNAL_EDITOR_ICON := preload("uid://da5t0jkc41bal")
const EXTERNAL_EDITOR_ICON := preload("uid://q1hy0uael7v6")

const SHOW_WINDOW_BUTTON_SETTING := "toolbar/window_mode_menu/enable"
const SHOW_WINDOW_BUTTON_TEXT_SETTING := "toolbar/window_mode_menu/show_button_text"
const SHOW_PLUGIN_BUTTON_SETTING := "toolbar/plugin_menu/enable"
const SHOW_PLUGIN_BUTTON_TEXT_SETTING := "toolbar/plugin_menu/show_button_text"
const PLUGIN_MENU_DISABLE_QUICK_SETTING := "toolbar/plugin_menu/hide_quick_settings_from_menu"
const SHOW_EDIT_IN_EXTERNAL_EDITOR_SETTING := "toolbar/external_editor/enable"
const HIDE_RENDERING_BUTTON := "toolbar/renderer/hide_renderer_button"

# const EDIT_IN_EXTERNAL_EDITOR_TOGGLE := "text_editor/external/use_external_editor"

var button_parent : Control
var dialog : Window
var plugin_enable_strings := PackedStringArray()
var rendering_options : Control

func _enable_plugin() -> void:
	pass

func _enter_tree() -> void:
	_get_or_add_setting(SHOW_WINDOW_BUTTON_SETTING, true)
	_get_or_add_setting(SHOW_WINDOW_BUTTON_TEXT_SETTING, true)
	_get_or_add_setting(SHOW_PLUGIN_BUTTON_SETTING, true)
	_get_or_add_setting(SHOW_PLUGIN_BUTTON_TEXT_SETTING, false)
	_get_or_add_setting(PLUGIN_MENU_DISABLE_QUICK_SETTING, true)
	_get_or_add_setting(SHOW_EDIT_IN_EXTERNAL_EDITOR_SETTING, true)
	var hide_renderer_button : bool= _get_or_add_setting(HIDE_RENDERING_BUTTON, true)
	ProjectSettings.save()
	_create_control()
	add_control_to_container(EditorPlugin.CONTAINER_TOOLBAR, button_parent)
	var hbox := H.Nodes.get_previous_sibling(button_parent)
	button_parent.reparent(hbox)
	H.Nodes.move_relative(button_parent, -1)
	rendering_options = H.Nodes.get_previous_sibling(button_parent)
	if hide_renderer_button:
		rendering_options.hide()


func _exit_tree() -> void:
	rendering_options.show()
	if button_parent and is_instance_valid(button_parent):
		button_parent.queue_free()

func _get_or_add_setting(setting: String, default_value: Variant) -> Variant:
	var plugin_config_prefix := Plugins.get_plugin_config_category(get_script().resource_path)
	return H.Settings.get_or_add(plugin_config_prefix.path_join(setting), default_value)

func _get_p_setting(setting: String) -> Variant:
	var plugin_config_prefix := Plugins.get_plugin_config_category(get_script().resource_path)
	return ProjectSettings.get_setting(plugin_config_prefix.path_join(setting))

func _create_control() -> void:
	button_parent = PanelContainer.new()
	button_parent.add_theme_stylebox_override(
		"panel",
		EditorInterface.get_base_control().get_theme_stylebox("PanelForeground", &"EditorStyles")
	)
	button_parent.name = "QuickSettingsPanel"
	var hbox := HBoxContainer.new()

	if _get_p_setting(SHOW_WINDOW_BUTTON_SETTING):
		var viewport_button := H.Controls.icon_menu_button(VIEWPORT_SETTINGS_ICON, false)
		viewport_button.tooltip_text = "Change the gameplay window mode"
		_create_viewport_popup(viewport_button)
		hbox.add_child(viewport_button)
		viewport_button.name = "QuickSettingsViewportButton"

	if _get_p_setting(SHOW_PLUGIN_BUTTON_SETTING):
		var plugin_button := H.Controls.icon_menu_button(PLUGIN_SETTINGS_ICON, false)
		if _get_p_setting(SHOW_PLUGIN_BUTTON_TEXT_SETTING):
			plugin_button.text = "Plugins"
		plugin_button.tooltip_text = "Enable/disable EditorPlugins"
		_create_plugin_popup(plugin_button.get_popup())
		hbox.add_child(plugin_button)
		plugin_button.name = "QuickSettingsPluginButton"

	if _get_p_setting(SHOW_EDIT_IN_EXTERNAL_EDITOR_SETTING):
		var es := EditorInterface.get_editor_settings()
		var on : bool = es.get("text_editor/external/use_external_editor")
		var external_button := Button.new()
		external_button.theme_type_variation = "EditorLogFilterButton"
		# external_button.add_theme_color_override(
		# 	"icon_pressed_color",
		# )
		external_button.flat = true
		external_button.toggle_mode = true
		external_button.tooltip_text = "Enable/disable external code editing"
		external_button.icon = EXTERNAL_EDITOR_ICON if on else INTERNAL_EDITOR_ICON
		external_button.toggled.connect(
			func(value: bool) -> void:
				print(value)
				es.set("text_editor/external/use_external_editor", value)
		)
		es.settings_changed.connect(_update_external_editor_setting.bind(external_button))
		hbox.add_child(external_button)
		external_button.name = "QuickSettingsExternalEditorButton"

	button_parent.add_child(hbox)

func _update_external_editor_setting(external_button: Button) -> void:
	print("updating external editor button")
	var es := EditorInterface.get_editor_settings()
	var value : bool = es.get("text_editor/external/use_external_editor")
	external_button.icon = EXTERNAL_EDITOR_ICON if value else INTERNAL_EDITOR_ICON
	external_button.set_pressed_no_signal(value)

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

	if _get_p_setting(SHOW_WINDOW_BUTTON_TEXT_SETTING):
		viewport_button.text = names[value]
	else:
		viewport_button.text = ""

	H.Signals.connect_if_not_connected(popup.about_to_popup, _create_viewport_popup.bind(viewport_button))
	H.Signals.connect_if_not_connected(
		popup.id_pressed,
		func(index):
			ProjectSettings.set_setting(setting_string, index)
			viewport_button.text = names[index]
			ProjectSettings.save()
	)

func _create_plugin_popup(popup: PopupMenu) -> void:
	popup.clear()
	popup.size.y = 0
	popup.hide_on_checkable_item_selection = false
	plugin_enable_strings.clear()
	var plugin_paths := Plugins.get_all_plugin_paths()

	if _get_p_setting(PLUGIN_MENU_DISABLE_QUICK_SETTING):
		for path in plugin_paths:
			if path.get_file() == "quick_settings":
			# if path.get_file() == get_script().resource_path.get_base_dir():
				plugin_paths.erase(path)
				break

	for i in plugin_paths.size():
		var plugin_path := plugin_paths[i]
		var plugin_enable_string := Plugins.get_plugin_enable_string_from_path(plugin_path)
		plugin_enable_strings.push_back(plugin_enable_string)
		var icon := Plugins.get_plugin_icon(plugin_path)
		var enabled := EditorInterface.is_plugin_enabled(plugin_enable_string)
		var display_name := plugin_enable_string.get_file()
		display_name = H.Strings.to_title_cased_spaced(display_name)
		if !icon:
			icon = PLUGIN_SETTINGS_ICON
		popup.add_icon_check_item(icon, display_name)
		popup.set_item_indent(i, plugin_enable_string.count("/") * H.Editor.Settings.scale)
		popup.set_item_checked(i, enabled)
		if !enabled:
			popup.set_item_icon_modulate(i, Color(Color.WHITE, 0.2))
		H.Signals.connect_if_not_connected(popup.about_to_popup, _create_plugin_popup.bind(popup))
		H.Signals.connect_if_not_connected(popup.index_pressed, _set_plugin_enabled.bind(popup))

func _set_plugin_enabled(index: int, popup: PopupMenu) -> void:
	for i in popup.item_count:
		popup.set_item_disabled(i, true)
	var inspector := EditorInterface.get_inspector()
	var edited_object := inspector.get_edited_object()
	inspector.edit(null)
	await get_tree().process_frame
	var enable_string := plugin_enable_strings[index]
	EditorInterface.set_plugin_enabled(
		enable_string,
		!EditorInterface.is_plugin_enabled(enable_string)
	)
	inspector.edit(edited_object)
	_create_plugin_popup(popup)


