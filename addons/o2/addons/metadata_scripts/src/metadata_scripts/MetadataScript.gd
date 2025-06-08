@tool
@icon("uid://cm3wwdg8y3x7m")
abstract class_name MetadataScript
extends Resource

var node : Node

const METADATA_SCRIPTS_PROPERTY := "metadata_scripts"
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

static func has_metadata_scripts(object: Object) -> bool:
	return object.has_meta(METADATA_SCRIPTS_PROPERTY)

static func get_metadata_scripts(object: Object) -> Array[MetadataScript]:
	if !has_metadata_scripts(object):
		return []
	return object.get_meta(METADATA_SCRIPTS_PROPERTY)

func add_to_object(object: Object) -> void:
	assert(object and is_instance_valid(Object), "Invalid object!")
	assert(object is Node, "Object is not a node!")
	var md_scripts : Array[MetadataScript] = []\
			if !has_metadata_scripts(object)\
			else get_metadata_scripts(object)
	md_scripts.push_back(self)

