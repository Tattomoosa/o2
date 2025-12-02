extends MenuButton

const Plugins := H.Editor.Plugins

const SETTING_HIDE_QUICK_SETTINGS := "hide_quick_settings"
const SETTING_HIDE_NESTED_PLUGINS := "hide_nested_plugins"

const NAME := "PluginsMenu"
const TOOLTIP_TEXT := "Enable/disable EditorPlugins"
const PLUGIN_SETTINGS_ICON := preload("uid://obguu32af2v")
const PLUGIN_DEFAULT_ICON := preload("uid://obguu32af2v")

# Will be added to SETTINGS and updated by quick_settings
var settings := {
	SETTING_HIDE_QUICK_SETTINGS: true,
	SETTING_HIDE_NESTED_PLUGINS: true,
}

var _plugin_icon_cache : Dictionary[String, Texture2D] = {}
var _popup : PopupMenu

func _ready() -> void:
	_popup = get_popup()
	icon = PLUGIN_SETTINGS_ICON
	tooltip_text = TOOLTIP_TEXT
	name = NAME
	# always refresh
	_popup.about_to_popup.connect(_create_popup)
	_popup.index_pressed.connect(_set_plugin_enabled)
	_create_popup()

func _create_popup() -> void:
	_popup.clear()
	_popup.reset_size()
	_popup.hide_on_checkable_item_selection = false
	var plugin_paths := Plugins.get_all_plugin_paths()

	var item_index := 0
	for plugin_path in plugin_paths:
		var plugin_enable_string := Plugins.get_plugin_enable_string_from_path(plugin_path)

		if _should_hide(plugin_enable_string):
			continue

		var enabled := EditorInterface.is_plugin_enabled(plugin_enable_string)
		var display_name := Plugins.get_plugin_display_name(plugin_path)

		_popup.add_icon_check_item(_get_icon(plugin_path), display_name)
		_popup.set_item_metadata(item_index, plugin_enable_string)
		_popup.set_item_checked(item_index, enabled)

		# dim disabled icons
		if !enabled:
			_popup.set_item_icon_modulate(item_index, Color(Color.WHITE, 0.6))
		if !settings[SETTING_HIDE_NESTED_PLUGINS]:
			# indent nested plugins
			var indent_amount := int(plugin_enable_string.count("/") * EditorInterface.get_editor_scale() / 2.0)
			_popup.set_item_indent(item_index, indent_amount)

		item_index += 1
	
func _get_icon(plugin_path: String) -> Texture2D:
	if plugin_path in _plugin_icon_cache:
		return _plugin_icon_cache[plugin_path]
	var plugin_icon := Plugins.get_plugin_icon(plugin_path)
	if !plugin_icon:
		plugin_icon = PLUGIN_DEFAULT_ICON
	plugin_icon = Plugins.ensure_icon_16x16_at_editor_scale(plugin_icon)
	_plugin_icon_cache[plugin_path] = plugin_icon
	return plugin_icon

func _set_plugin_enabled(index: int) -> void:
	for i in _popup.item_count:
		_popup.set_item_disabled(i, true)
	var inspector := EditorInterface.get_inspector()
	var edited_object := inspector.get_edited_object()
	inspector.edit(null)
	await get_tree().process_frame
	var enable_string : String = _popup.get_item_metadata(index)
	EditorInterface.set_plugin_enabled(enable_string, !EditorInterface.is_plugin_enabled(enable_string))
	inspector.edit(edited_object)
	_create_popup()

func _should_hide(enable_string: String) -> bool:
	if settings[SETTING_HIDE_QUICK_SETTINGS]:
		if enable_string.get_file() == "quick_settings":
			return true
	if settings[SETTING_HIDE_NESTED_PLUGINS]:
		for plugin_path in Plugins.get_all_plugin_paths():
			var p_enable_string := Plugins.get_plugin_enable_string_from_path(plugin_path)
			if enable_string == p_enable_string:
				continue
			if p_enable_string in enable_string:
				return true
	return false
