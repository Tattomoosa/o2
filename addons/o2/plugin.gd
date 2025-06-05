@tool
extends EditorPlugin

const O2_PATH := "src/O2.gd"

func _enable_plugin() -> void:
	var path := (get_script() as Script).resource_path.get_base_dir()
	var o2_path := path.path_join(O2_PATH)
	add_autoload_singleton("O2", o2_path)
	EditorInterface.set_plugin_enabled("o2/addons/primitive_resources", true)
	# EditorInterface.set_plugin_enabled("o2/addons/exposed_resource_properties", true)
	_add_commands()


func _disable_plugin() -> void:
	remove_autoload_singleton("O2")
	EditorInterface.set_plugin_enabled("o2/addons/primitive_resources", false)
	# EditorInterface.set_plugin_enabled("o2/addons/exposed_resource_properties", false)
	_remove_commands()


func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	pass


func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	pass


func _add_commands() -> void:
	var cmd_palette := EditorInterface.get_command_palette()
	cmd_palette.add_command(
		"Refresh O2 Addons",
		"refresh_o2_addons",
		_refresh
	)

func _refresh() -> void:
	EditorInterface.set_plugin_enabled("o2", false)
	EditorInterface.set_plugin_enabled("o2", true)

func _remove_commands() -> void:
	var cmd_palette := EditorInterface.get_command_palette()
	cmd_palette.remove_command("refresh_o2_addons")