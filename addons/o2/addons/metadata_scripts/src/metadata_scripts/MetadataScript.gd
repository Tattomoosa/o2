@tool
abstract class_name MetadataScript
extends Resource

var node : Node

const _Signals := O2.Helpers.Signals

func _init() -> void:
	if Engine.is_editor_hint():
		var display_name := (get_script() as Script).get_global_name()
		resource_name = display_name.replace("MetadataScript_", "")

func _ready() -> void:
	pass

func _enter_tree() -> void:
	pass

func _exit_tree() -> void:
	pass

func ready() -> void:
	_ready()

func tree_entered(p_node: Node) -> void:
	node = p_node
	_Signals.connect_if_not_connected(node.ready, ready)
	_enter_tree()

func tree_exiting() -> void:
	_Signals.disconnect_if_connected(node.ready, ready)
	_exit_tree()

static func can_attach_to(p_node: Node) -> bool:
	return p_node != null
