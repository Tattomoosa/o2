@tool
extends O2.TreeWatcher.TreeWatcherPlugin

const Signals := H.Signals

func node_ready(node: Node) -> void:
	if MetadataScript.has_metadata_scripts(node):
		for s in MetadataScript.get_metadata_scripts(node):
			s.attach_to(node)

func node_exiting(node: Node) -> void:
	if MetadataScript.has_metadata_scripts(node):
		for s in MetadataScript.get_metadata_scripts(node):
			s._exit_tree()