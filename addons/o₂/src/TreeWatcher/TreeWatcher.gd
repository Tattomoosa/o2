@tool
extends RefCounted

const Settings := H.Settings
const Nodes := H.Nodes

const TreeWatcherPlugin := preload("uid://jdhkmwip1txo")
const TREE_WATCHER_PLUGINS_SETTING := "O₂/tree_watcher/tree_watcher_plugins"

var plugins : Array[TreeWatcherPlugin] = []
var l := O2.logger.add_substream(
	O2.Logging.LogLevel.DEBUG,
	&"TreeWatcher"
)

func _init(root: Node) -> void:
	if !root:
		return
	_load_plugins()
	_node_entered(root)
	for child in Nodes.get_descendents(root):
		_node_entered(child)

func _node_entered(node: Node) -> void:
	if !node.child_entered_tree.is_connected(_node_entered):
		node.child_entered_tree.connect(_node_entered)
	if !node.ready.is_connected(_node_ready):
		node.ready.connect(_node_ready.bind(node))
	if !node.child_exiting_tree.is_connected(_node_exiting):
		node.child_exiting_tree.connect(_node_exiting)
	for plugin in plugins:
		plugin.node_entered(node)

func _node_ready(node: Node) -> void:
	for plugin in plugins:
		plugin.node_ready(node)

func _node_exiting(node: Node) -> void:
	if node.child_entered_tree.is_connected(_node_entered):
		node.child_entered_tree.disconnect(_node_entered)
	if node.child_exiting_tree.is_connected(_node_entered):
		node.child_exiting_tree.disconnect(_node_exiting)
	for plugin in plugins:
		plugin.node_exiting(node)

static func register_plugin(plugin: TreeWatcherPlugin) -> void:
	var plugin_paths : Array = Settings.get_or_add(TREE_WATCHER_PLUGINS_SETTING, PackedStringArray([]))
	var plugin_uid := ResourceLoader.get_resource_uid((plugin.get_script() as Script).resource_path)
	var plugin_uid_path := ResourceUID.id_to_text(plugin_uid)
	if plugin_uid_path not in plugin_paths:
		plugin_paths.push_back(plugin_uid_path)
	ProjectSettings.set_setting(TREE_WATCHER_PLUGINS_SETTING, plugin_paths)
	ProjectSettings.add_property_info({
		"name": TREE_WATCHER_PLUGINS_SETTING,
		"type": TYPE_ARRAY,
		"hint": PROPERTY_HINT_TYPE_STRING,
		"hint_string": "4/13:", #TYPE_STRING/PROPERTY_HINT_FILE
	})
	ProjectSettings.save()

static func unregister_plugin(plugin: TreeWatcherPlugin) -> void:
	var plugin_paths : Array = Settings.get_or_add(TREE_WATCHER_PLUGINS_SETTING, PackedStringArray([]))
	var plugin_uid := ResourceLoader.get_resource_uid((plugin.get_script() as Script).resource_path)
	var plugin_uid_path := ResourceUID.id_to_text(plugin_uid)
	if plugin_uid in plugin_paths:
		plugin_paths.erase(plugin_uid_path)
	ProjectSettings.set_setting(TREE_WATCHER_PLUGINS_SETTING, plugin_paths)

func _load_plugins() -> void:
	var plugin_paths : Array = Settings.get_or_add(TREE_WATCHER_PLUGINS_SETTING, PackedStringArray([]))
	var plugin_names := PackedStringArray()
	for path in plugin_paths:
		var plugin_script : Script = load(path)
		if !plugin_script:
			push_error("Plugin script %s not found!" % plugin_script)
			continue
		if "new" not in plugin_script:
			push_error("Plugin script %s missing 'new' method!" % plugin_script)
			continue
		plugins.push_back(plugin_script.new())
		plugin_names.push_back(H.Files.get_file_without_extension(plugin_script.resource_path))
	l.info("Loaded plugins: ", ",".join(plugin_names))
	
