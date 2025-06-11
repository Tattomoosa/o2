@tool
extends O2.TreeWatcher.TreeWatcherPlugin

const METADATA_SCRIPTS_PROPERTY := "metadata_scripts"
const Signals := H.Signals

func node_entered(node: Node) -> void:
	if node.has_meta(METADATA_SCRIPTS_PROPERTY):
		for s in node.get_meta(METADATA_SCRIPTS_PROPERTY):
			if !s.node:
				s.node = node
			elif s.node != node:
				push_error("MetadataScript.node is attached to a node it doesn't belong to")

func node_exiting(node: Node) -> void:
	if node.has_meta(METADATA_SCRIPTS_PROPERTY):
		for s in node.get_meta(METADATA_SCRIPTS_PROPERTY):
			s._exit_tree()
