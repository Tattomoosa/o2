@tool
extends EditorPlugin

# TODO need to remove this to release separately
const Plugins := H.Editor.Plugins
const Strings := H.Strings
const Settings := H.Settings

const SETTINGS_PREFIX := "quick_settings"
const TOOLBAR := "toolbar"
const ENABLED := "enabled"

const WindowModeMenu := preload("uid://daxjeylx3yryg")
const QuickSettings := preload("uid://cec8h75dbk681")
const PluginMenu := preload("uid://cogh04pjlu874")
const ExternalEditorToggle := preload("uid://286bb2mh7ial")

const DEFAULT : Array[Script] = [
	WindowModeMenu,
	ExternalEditorToggle,
	PluginMenu,
]

var quick_settings_toolbar : Control
var watched_settings : Dictionary[String, Variant]

func _enter_tree() -> void:
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
		if _get_or_add_setting(toolbar_setting.path_join(ENABLED), true):
			var plugin : Node = plugin_script.new()
			quick_settings_toolbar.add_child(plugin)
			var toolbar_plugin_settings := toolbar_setting.path_join("settings")
			# register plugin requested settings
			if "settings" in plugin:
				for key in plugin.settings:
					var setting_name := toolbar_plugin_settings.path_join(key)
					plugin.settings[key] = _get_or_add_setting(setting_name, plugin.settings[key])
	add_control_to_container(EditorPlugin.CONTAINER_TOOLBAR, quick_settings_toolbar)
	quick_settings_toolbar.get_parent().move_child(quick_settings_toolbar, quick_settings_toolbar.get_index() - 1)

	ProjectSettings.save()
	ProjectSettings.settings_changed.connect(_project_settings_changed)

func _get_toolbar_setting(script_name: String) -> String:
	return SETTINGS_PREFIX.path_join(TOOLBAR).path_join(script_name)

func _get_or_add_setting(setting: String, default_value: Variant) -> Variant:
	var value : Variant = Settings.get_or_add(setting, default_value)
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
