@tool
@icon("uid://b5258mnsr6qim")
extends EditorPlugin

const O2_INSTANCE := "o2"
const O2_PATH := "src/O2.gd"
const Plugins := O2.Helpers.Editor.Plugins
const ICON := preload("uid://b5258mnsr6qim")
const InspectorContextMenu := preload("uid://drhs82tyfy2j2")

const REIMPORT_ICON_COMMAND := "reimport_editor_scale"

const EditorSceneRootChangeNotifier := preload("uid://q222j6y6bix6")

const PLUGINS : PackedStringArray = [
	"metadata_scripts",
	"variant_resources",
]

var scene_change_notifier : EditorSceneRootChangeNotifier
var subplugin_roots : PackedStringArray
var inspector_context_menu : InspectorContextMenu

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
	for autoload in get_tree().root.get_children():
		if autoload.name == O2_INSTANCE:
			autoload.tree_watcher = autoload.TreeWatcher.new(scene_root)

func _enter_tree() -> void:
	inspector_context_menu = InspectorContextMenu.new()
	add_inspector_plugin(inspector_context_menu)
	add_tool_menu_item(REIMPORT_ICON_COMMAND, _reimport_icons)
	scene_change_notifier = EditorSceneRootChangeNotifier.new()
	scene_change_notifier.scene_root_changed.connect(_on_scene_changed)

func _exit_tree() -> void:
	remove_inspector_plugin(inspector_context_menu)
	remove_tool_menu_item(REIMPORT_ICON_COMMAND)
	inspector_context_menu.queue_free()

func _reimport_icons() -> void:
	var files := O2.Helpers.Files.get_all_files("res://", "svg")
	EditorInterface.get_resource_filesystem().reimport_files(files)

		


	