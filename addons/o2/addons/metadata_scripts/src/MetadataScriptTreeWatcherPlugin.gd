@tool
extends O2.TreeWatcher.TreeWatcherPlugin

const METADATA_SCRIPTS_PROPERTY := "metadata_scripts"

func node_entered(node: Node) -> void:
	if node.has_meta(METADATA_SCRIPTS_PROPERTY):
		for s in node.get_meta(METADATA_SCRIPTS_PROPERTY):
			s.tree_entered(node)

func node_exiting(node: Node) -> void:
	if node.has_meta(METADATA_SCRIPTS_PROPERTY):
		for s in node.get_meta(METADATA_SCRIPTS_PROPERTY):
			s.tree_exiting()
