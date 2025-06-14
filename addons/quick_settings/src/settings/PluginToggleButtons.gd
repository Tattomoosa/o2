extends PanelContainer

const Plugins := H.Editor.Plugins

const SETTING_PLUGINS_TO_TOGGLE := "toggle_plugin_list"

const PLUGIN_DEFAULT_ICON := preload("uid://obguu32af2v")

var settings := {
	SETTING_PLUGINS_TO_TOGGLE: {},
}
var settings_info := {
	SETTING_PLUGINS_TO_TOGGLE: {
		# name gets patched in by quick_settings
		&"type": TYPE_DICTIONARY,
		&"hint": PROPERTY_HINT_TYPE_STRING,
		&"hint_string": "4/13:plugin.cfg;1:", # (TYPE_STRING/PROPERTY_HINT_DIR:;TYPE_BOOL:"")
	}
}

var _plugin_icon_cache : Dictionary[String, Texture2D] = {}
var _plugin_watcher := Plugins.Watcher.new()
var _plugin_buttons : Dictionary[String, Node]= {}

func _init() -> void:
	_plugin_watcher.subscribe(_plugin_entered, _plugin_exiting)
	var plugin_paths := Plugins.get_all_plugin_paths()
	for plugin_path in plugin_paths:
		var config_path := Plugins.get_plugin_config_file_path(plugin_path)
		settings[SETTING_PLUGINS_TO_TOGGLE][config_path] = false

func _ready() -> void:
	name = "TogglePluginsMenu"
	_create()

func _create() -> void:
	var hbox := HBoxContainer.new()
	add_child(hbox)
	for plugin_config_path in settings[SETTING_PLUGINS_TO_TOGGLE]:
		if !settings[SETTING_PLUGINS_TO_TOGGLE][plugin_config_path]:
			continue
		var plugin_path := Plugins.get_plugin_path_from_config_path(plugin_config_path)
		var enable_string := Plugins.get_plugin_enable_string_from_path(plugin_path)
		var button := Button.new()
		button.icon = _get_icon(plugin_path)
		button.tooltip_text = Plugins.get_plugin_display_name(plugin_config_path)
		var enabled := EditorInterface.is_plugin_enabled(enable_string)
		_update_plugin_button(enabled, button)
		button.pressed.connect(_set_plugin_enabled.bindv([plugin_config_path, button]))
		hbox.add_child(button)
		_plugin_buttons[plugin_path] = button
	if !hbox.get_child_count():
		hide()

func _update_plugin_button(enabled: bool, button: Button) -> void:
	button.modulate = Color.WHITE if enabled else Color(0.5, 0.5, 0.5, 0.5)

func _get_icon(plugin_path: String) -> Texture2D:
	if plugin_path in _plugin_icon_cache:
		return _plugin_icon_cache[plugin_path]
	var plugin_icon := Plugins.get_plugin_icon(plugin_path)
	if !plugin_icon:
		plugin_icon = PLUGIN_DEFAULT_ICON
	plugin_icon = Plugins.ensure_icon_16x16_at_editor_scale(plugin_icon)
	_plugin_icon_cache[plugin_path] = plugin_icon
	return plugin_icon

func _set_plugin_enabled(plugin_path: String, button: Button) -> void:
	var inspector := EditorInterface.get_inspector()
	var edited_object := inspector.get_edited_object()
	inspector.edit(null)
	await get_tree().process_frame
	var enable_string := Plugins.get_plugin_enable_string_from_path(plugin_path)
	EditorInterface.set_plugin_enabled(enable_string, !EditorInterface.is_plugin_enabled(enable_string))
	inspector.edit(edited_object)
	_update_plugin_button(EditorInterface.is_plugin_enabled(enable_string), button)

func _plugin_entered(plugin_path: String) -> void:
	if plugin_path in _plugin_buttons:
		var button := _plugin_buttons[plugin_path]
		var enabled := Plugins.is_enabled(plugin_path)
		_update_plugin_button(enabled, button)

func _plugin_exiting(plugin_path: String) -> void:
	if plugin_path in _plugin_buttons:
		var button : Button = _plugin_buttons[plugin_path]
		var enabled := Plugins.is_enabled(plugin_path)
		_update_plugin_button(enabled, button)