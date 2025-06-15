@tool
extends O2.TreeWatcher.TreeWatcherPlugin

func node_entered(node: Node) -> void:
	O2.logger.debug("%s entered tree" % node)

func node_ready(node: Node) -> void:
	O2.logger.debug("%s ready" % node)

func node_exiting(node: Node) -> void:
	O2.logger.debug("%s exiting tree" % node)