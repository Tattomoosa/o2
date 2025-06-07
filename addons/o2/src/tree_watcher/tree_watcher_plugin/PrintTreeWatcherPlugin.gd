@tool
extends O2.TreeWatcher.TreeWatcherPlugin

func node_entered(node: Node) -> void:
	o2.logger.debug("%s entered tree" % node)

func node_exiting(node: Node) -> void:
	o2.logger.debug("%s exiting tree" % node)