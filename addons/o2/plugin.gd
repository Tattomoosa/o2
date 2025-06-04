@tool
extends EditorPlugin

const O2_PATH := "src/O2.gd"

func _enable_plugin() -> void:
	var path := (
		(get_script() as Script)
			.resource_path
			.get_base_dir()
			.path_join(O2_PATH)
	)
	add_autoload_singleton("O2", path)


func _disable_plugin() -> void:
	remove_autoload_singleton("O2")


func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	pass


func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	pass
