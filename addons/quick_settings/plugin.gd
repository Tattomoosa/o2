@tool
extends EditorPlugin

# TODO need to remove this to release separately
const Plugins := H.Editor.Plugins
const Strings := H.Strings
const Settings := H.Settings

const SETTINGS_PREFIX := "quick_settings"
const TOOLBAR := "toolbar"
const SETTINGS := "settings"
const ENABLED := "enabled"

const QuickSettings := preload("uid://cec8h75dbk681")

# default plugins
const WindowModeMenu := preload("uid://daxjeylx3yryg")
const ExternalEditorToggle := preload("uid://cq6ukaydjf1y")
const PluginMenu := preload("uid://cogh04pjlu874")
const PluginToggleButtons := preload("uid://c0l3gsehyq221")

const DEFAULT : Array[Script] = [
	WindowModeMenu,
	ExternalEditorToggle,
	PluginMenu,
	PluginToggleButtons,
]

var quick_settings_toolbar : Control
var watched_settings : Dictionary[String, Variant]

func _enter_tree() -> void:
	name = "QuickSettings"
	# TODO make sure this means it'll be to the left of the spinner if the spinner is showing
	await get_tree().process_frame
	_startup()

func _exit_tree() -> void:
	_shutdown()

func _startup() -> void:
	# guard
	watched_settings.clear()
	if ProjectSettings.settings_changed.is_connected(_project_settings_changed):
		ProjectSettings.settings_changed.disconnect(_project_settings_changed)

	quick_settings_toolbar = QuickSettings.new()
	for plugin_script in DEFAULT:
		var plugin_name : String = plugin_script.resource_path.get_file().replace(".gd", "").to_snake_case()
		var toolbar_setting := _get_toolbar_setting(plugin_name)
		if _get_or_add_setting(toolbar_setting + "_" + ENABLED, true):
			var plugin : Node = plugin_script.new()
			quick_settings_toolbar.add(plugin)
			var plugin_settings := _get_items_settings(plugin_name)
			# register plugin requested settings
			if "settings" in plugin:
				for key in plugin.settings:
					var setting_name := plugin_settings.path_join(key)
					var setting_info : Dictionary = (
						plugin.settings_info[key]
						if "settings_info" in plugin
							and key in plugin.settings_info
						else {}
					)
					plugin.settings[key] = _get_or_add_setting(setting_name, plugin.settings[key], setting_info)
	add_control_to_container(EditorPlugin.CONTAINER_TOOLBAR, quick_settings_toolbar)
	quick_settings_toolbar.get_parent().move_child(quick_settings_toolbar, quick_settings_toolbar.get_index() - 1)

	ProjectSettings.save()
	ProjectSettings.settings_changed.connect(_project_settings_changed)

func _get_toolbar_setting(script_name: String) -> String:
	return SETTINGS_PREFIX.path_join(TOOLBAR).path_join(script_name)

func _get_items_settings(script_name: String) -> String:
	return SETTINGS_PREFIX.path_join(SETTINGS).path_join(script_name)

func _get_or_add_setting(
	setting: String,
	default_value: Variant,
	setting_property_info: Dictionary = {}
) -> Variant:
	# add new keys with their default value
	if default_value is Dictionary and ProjectSettings.has_setting(setting):
		var settings_value : Dictionary = ProjectSettings.get_setting(setting)
		for key in default_value:
			if key not in settings_value:
				settings_value[key] = default_value[key]
		ProjectSettings.set_setting(setting, settings_value)

	if !ProjectSettings.has_setting(setting):
		ProjectSettings.set_setting(setting, default_value)
		if default_value != null:
			ProjectSettings.set_initial_value(setting, default_value)

	if setting_property_info:
		setting_property_info["name"] = setting
		ProjectSettings.add_property_info(setting_property_info)
	var value : Variant = ProjectSettings.get_setting(setting)
	if setting not in watched_settings:
		watched_settings[setting] = value
	return value

func _project_settings_changed() -> void:
	for setting in watched_settings:
		if ProjectSettings.get_setting(setting) != watched_settings[setting]:
			_reload()

func _shutdown() -> void:
	remove_control_from_container(EditorPlugin.CONTAINER_TOOLBAR, quick_settings_toolbar)
	quick_settings_toolbar.queue_free()

func _reload() -> void:
	_shutdown()
	_startup()