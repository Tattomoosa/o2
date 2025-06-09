@tool
extends EditorPlugin

const O2_INSTANCE := "o2"
const O2_PATH := "src/O2.gd"
# const SUB_ADDONS_ROOT := "o2/addons/"
const Plugins := O2.Helpers.Editor.Plugins

const EditorSceneRootChangeNotifier := preload("uid://q222j6y6bix6")

const PLUGINS : PackedStringArray = [
	"metadata_scripts",
	"variant_resources",
]

var scene_change_notifier : EditorSceneRootChangeNotifier
var subplugin_roots : PackedStringArray

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
	scene_change_notifier = EditorSceneRootChangeNotifier.new()
	scene_change_notifier.scene_root_changed.connect(_on_scene_changed)


func _exit_tree() -> void:
	pass

		


	