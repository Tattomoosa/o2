@tool
extends EditorPlugin

const O2_PATH := "src/O2.gd"

const PLUGINS : PackedStringArray = [
	"metadata_scripts",
	"variant_resources",
]

var scene_change_notifier : EditorSceneRootChangeNotifier

func _enable_plugin() -> void:
	print("O2: ENABLED")
	var path := (get_script() as Script).resource_path.get_base_dir()
	var o2_path := path.path_join(O2_PATH)
	add_autoload_singleton("O2", o2_path)
	for plugin in PLUGINS:
		EditorInterface.set_plugin_enabled("o2/addons/" + plugin, true)

func _disable_plugin() -> void:
	print("O2: DISABLED")
	for plugin in PLUGINS:
		EditorInterface.set_plugin_enabled("o2/addons/" + plugin, false)
	remove_autoload_singleton("O2")


func _on_scene_changed(scene_root: Node) -> void:
	if !scene_root:
		return
	for autoload in get_tree().root.get_children():
		if autoload.name == "O2":
			autoload.tree_watcher = autoload.TreeWatcher.new(scene_root)


func _enter_tree() -> void:
	print("O2: ENTER TREE")
	scene_change_notifier = EditorSceneRootChangeNotifier.new()
	scene_change_notifier.scene_root_changed.connect(_on_scene_changed)


func _exit_tree() -> void:
	print("O2: EXIT TREE")

# https://github.com/godotengine/godot/issues/97427
class EditorSceneRootChangeNotifier extends RefCounted:
	signal scene_root_changed(node: Node)

	func _init() -> void:
		var viewport_2d := EditorInterface.get_editor_viewport_2d()
		viewport_2d.child_entered_tree.connect(scene_root_changed.emit)
		viewport_2d.child_exiting_tree.connect(scene_root_changed.emit.bind(null).unbind(1))
		


	