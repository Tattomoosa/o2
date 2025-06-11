@tool

# TODO should support nested folders like godot does
# eg o2/addons/foo/bar/plugin.cfg
static func get_subplugin_roots(plugin: EditorPlugin) -> PackedStringArray:
	var path := get_plugin_root_dir(plugin)
	var subplugin_root_dir := path.path_join("addons")
	var subplugin_names := H.Files.get_subdirectories(subplugin_root_dir)
	return H.Files.path_join_all(subplugin_root_dir, subplugin_names)

static func get_plugin_root_dir(plugin: EditorPlugin) -> String:
	return (plugin.get_script() as Script).resource_path.get_base_dir()

static func get_plugin_root_dir_name(plugin: EditorPlugin) -> String:
	return get_plugin_root_dir(plugin).get_file()

static func get_subplugin_names(plugin: EditorPlugin) -> PackedStringArray:
	var path := get_plugin_root_dir(plugin)
	var subplugin_root_dir := path.path_join("addons")
	return H.Files.get_subdirectories(subplugin_root_dir)

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

static func is_subplugin_enabled_in_settings(plugin: EditorPlugin, subplugin_name: String) -> bool:
	var setting_name := get_subplugin_enabled_setting_name(plugin, subplugin_name)
	return H.Settings.get_or_add(setting_name, true)

static func get_subplugin_category(plugin: EditorPlugin, subplugin_name: String) -> String:
	var plugin_name := get_plugin_root_dir_name(plugin)
	return plugin_name.path_join(subplugin_name)

static func enable_subplugins(plugin: EditorPlugin) -> void:
	for subplugin_name in get_subplugin_names(plugin):
		if is_subplugin_enabled_in_settings(plugin, subplugin_name):
			var setting_name := get_subplugin_enabled_setting_name(plugin, subplugin_name)
			var enabled : bool = H.Settings.get_or_add(setting_name, true)
			var enable_string := get_plugin_root_dir(plugin).path_join("addons").path_join(subplugin_name)
			enable_string = enable_string.replace("res://addons/", "")
			if !EditorInterface.is_plugin_enabled(enable_string):
				EditorInterface.set_plugin_enabled(enable_string, enabled)
	ProjectSettings.save()

static func disable_subplugins(plugin: EditorPlugin) -> void:
	for subplugin_name in get_subplugin_names(plugin):
		var enable_string := get_plugin_root_dir(plugin).path_join("addons").path_join(subplugin_name)
		enable_string = enable_string.replace("res://addons/", "")
		if EditorInterface.is_plugin_enabled(enable_string):
			EditorInterface.set_plugin_enabled(enable_string, false)

static func get_all_plugin_paths() -> PackedStringArray:
	var plugin_dirs := PackedStringArray()
	var cfg_file_paths := H.Files.get_all_files("res://addons/", ["cfg"])
	for cfg_path in cfg_file_paths:
		if cfg_path.get_file() == "plugin.cfg":
			plugin_dirs.push_back(cfg_path.get_base_dir())
	return plugin_dirs

static func get_plugin_enable_string_from_path(path: String) -> String:
	if path.ends_with(".gd"):
		path = path.get_base_dir()
	return path.replace("res://addons/", "")

# TODO
static func get_plugin_icon(plugin_path: String) -> Texture2D:
	var config_file := get_plugin_config_file(plugin_path)
	if config_file.has_section_key("plugin", "icon"):
		var icon_path : String = config_file.get_value("plugin", "icon", null)
		return load(icon_path)
	return null

static func get_plugin_config_category(plugin_path: String) -> String:
	var plugin_enable_string := get_plugin_enable_string_from_path(plugin_path)
	return plugin_enable_string.replace("addons/", "")

static func get_plugin_config_file(plugin_path: String) -> ConfigFile:
	var config_file := ConfigFile.new()
	config_file.load(plugin_path.path_join("plugin.cfg"))
	return config_file

static func get_plugin_script(plugin_path: String) -> Script:
	var config_file := get_plugin_config_file(plugin_path)
	var script_name : String = config_file.get_value("plugin", "script", "")
	var script : GDScript = load(plugin_path.path_join(script_name))
	return script
	



# static func get_plugin_script(plugin_path: String) -> Script:
# 	var script := Script.new()
