@tool

const Files := O2.Helpers.Files
const Settings := O2.Helpers.Settings

# TODO should support nested folders like godot does
# eg o2/addons/foo/bar/plugin.cfg
static func get_subplugin_roots(plugin: EditorPlugin) -> PackedStringArray:
	var path := get_plugin_root_dir(plugin)
	var subplugin_root_dir := path.path_join("addons")
	var subplugin_names := Files.get_subdirectories(subplugin_root_dir)
	return Files.path_join_all(subplugin_root_dir, subplugin_names)

static func get_plugin_root_dir(plugin: EditorPlugin) -> String:
	return (plugin.get_script() as Script).resource_path.get_base_dir()

static func get_plugin_root_dir_name(plugin: EditorPlugin) -> String:
	return get_plugin_root_dir(plugin).get_file()

static func get_subplugin_names(plugin: EditorPlugin) -> PackedStringArray:
	var path := get_plugin_root_dir(plugin)
	var subplugin_root_dir := path.path_join("addons")
	return Files.get_subdirectories(subplugin_root_dir)

static func get_subplugin_root_dir(plugin: EditorPlugin, subplugin_name: String) -> String:
	var path := get_plugin_root_dir(plugin)
	var subplugin_root_dir := path.path_join("addons")
	return subplugin_root_dir.path_join(subplugin_name)

# static func add_missing_subplugin_enable_settings(plugin: EditorPlugin) -> void:
# 	for subplugin_name in get_subplugin_names(plugin):
# 		var setting := get_subplugin_enabled_setting_name(plugin, subplugin_name)
# 		Settings.get_or_add(setting, true)

static func get_subplugin_enabled_setting_name(plugin: EditorPlugin, subplugin_name: String) -> String:
	var category := get_subplugin_category(plugin, subplugin_name)
	return category.path_join("enabled")

static func is_subplugin_enabled(plugin: EditorPlugin, subplugin_name: String) -> bool:
	var setting_name := get_subplugin_enabled_setting_name(plugin, subplugin_name)
	return Settings.get_or_add(setting_name, true)

static func get_subplugin_category(plugin: EditorPlugin, subplugin_name: String) -> String:
	var plugin_name := get_plugin_root_dir_name(plugin)
	return plugin_name.path_join(subplugin_name)

static func enable_subplugins(plugin: EditorPlugin) -> void:
	for subplugin_name in get_subplugin_names(plugin):
		if is_subplugin_enabled(plugin, subplugin_name):
			var setting_name := get_subplugin_enabled_setting_name(plugin, subplugin_name)
			var enabled : bool = Settings.get_or_add(setting_name, true)
			var enable_string := get_plugin_root_dir(plugin).path_join("addons").path_join(subplugin_name)
			enable_string = enable_string.replace("res://addons/", "")
			print(enable_string)
			EditorInterface.set_plugin_enabled(
					enable_string, enabled)

static func disable_subplugins(plugin: EditorPlugin) -> void:
	for subplugin_name in get_subplugin_names(plugin):
		var enable_string := get_plugin_root_dir(plugin).path_join("addons").path_join(subplugin_name)
		enable_string = enable_string.replace("res://addons/", "")
		EditorInterface.set_plugin_enabled(enable_string, false)

