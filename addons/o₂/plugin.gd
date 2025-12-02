@tool
@icon("uid://b5258mnsr6qim")
extends EditorPlugin

const O2_INSTANCE := "o2"
const O2_PATH := "src/O2.gd"
const Plugins := O2.EditorExtensions.Plugins
const ICON := preload("uid://b5258mnsr6qim")
const InspectorContextMenu := preload("uid://drhs82tyfy2j2")

const REIMPORT_ICON_TOOL := "Reimport Editor Scaled Icons"
const SHOW_MOUSE_COMMAND := "show_mouse"

const EditorSceneRootChangeNotifier := preload("uid://q222j6y6bix6")

var scene_change_notifier : EditorSceneRootChangeNotifier
var subplugin_roots : PackedStringArray
var inspector_context_menu : InspectorContextMenu
# var logging_panel :

func _get_plugin_icon() -> Texture2D:
	return ICON

func _enable_plugin() -> void:
	var path := (get_script() as Script).resource_path.get_base_dir()
	var o2_path := path.path_join(O2_PATH)
	add_autoload_singleton(O2_INSTANCE, o2_path)
	Plugins.enable_subplugins(self)

func _disable_plugin() -> void:
	Plugins.disable_subplugins(self)
	remove_autoload_singleton(O2_INSTANCE)

func _on_scene_changed(scene_root: Node) -> void:
	if !scene_root:
		return
	O2.instance._tree_watcher = O2.TreeWatcher.new(scene_root)

func _enter_tree() -> void:
	name = "O₂"
	inspector_context_menu = InspectorContextMenu.new()
	add_inspector_plugin(inspector_context_menu)
	add_tool_menu_item(REIMPORT_ICON_TOOL, _reimport_icons)
	EditorInterface.get_command_palette().add_command("Set Mouse Mode Visible", SHOW_MOUSE_COMMAND, _show_mouse)
	scene_change_notifier = EditorSceneRootChangeNotifier.new()
	scene_change_notifier.scene_root_changed.connect(_on_scene_changed)

func _exit_tree() -> void:
	EditorInterface.get_command_palette().remove_command(SHOW_MOUSE_COMMAND)
	remove_inspector_plugin(inspector_context_menu)
	remove_tool_menu_item(REIMPORT_ICON_TOOL)

func _reimport_icons() -> void:
	var files := H.Files.get_all_files("res://", ["svg"])
	EditorInterface.get_resource_filesystem().reimport_files(files)

func _show_mouse() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		


	