@tool
@icon("uid://cm3wwdg8y3x7m")
abstract class_name MetadataScript
extends Resource

var node : Node:
	get: return _node

var _node : Node

const METADATA_SCRIPTS_PROPERTY := "metadata_scripts"

func _init() -> void:
	resource_local_to_scene = true
	if Engine.is_editor_hint():
		var display_name := (get_script() as Script).get_global_name()
		resource_name = display_name.replace("MetadataScript_", "")

func _ready() -> void:
	pass

func _enter_tree() -> void:
	pass

func _exit_tree() -> void:
	pass

static func can_attach_to(p_node: Node) -> bool:
	return p_node != null

static func has_metadata_scripts(object: Object) -> bool:
	if !object:
		push_error("%s is null" % object)
		return false
	return object.has_meta(METADATA_SCRIPTS_PROPERTY)

static func get_metadata_scripts(object: Object) -> Array[MetadataScript]:
	if !has_metadata_scripts(object):
		return []
	return object.get_meta(METADATA_SCRIPTS_PROPERTY)

func attach_to(p_node : Node) -> void:
	assert(p_node and p_node is Node and is_instance_valid(p_node), "Invalid node")
	assert(can_attach_to(p_node), "Cannot attach to this object")
	if _node != null:
		detach()
	_node = p_node
	if !has_metadata_scripts(node):
		node.set_meta(METADATA_SCRIPTS_PROPERTY, [] as Array[MetadataScript])
	var md_scripts := get_metadata_scripts(node)
	if self not in md_scripts:
		md_scripts.push_back(self)
	if !node.tree_entered.is_connected(_enter_tree):
		node.tree_entered.connect(_enter_tree)
	if !node.tree_exiting.is_connected(_exit_tree):
		node.tree_exiting.connect(_exit_tree)
	if !node.ready.is_connected(_ready):
		node.ready.connect(_ready)
	if node.is_node_ready():
		_ready()

func detach() -> void:
	if !_node: return
	for s in _node.get_signal_list():
		print(s)
		# if s.callable.get_object() == self:
		# 	s.signal.disconnect(s.callable)
	if node.tree_entered.is_connected(_enter_tree):
		node.tree_entered.disconnect(_enter_tree)
	if node.tree_exiting.is_connected(_exit_tree):
		node.tree_exiting.disconnect(_exit_tree)
	if node.ready.is_connected(_ready):
		node.ready.disconnect(_ready)

func _validate_property(property: Dictionary) -> void:
	if !Engine.is_editor_hint:
		return
	return
	match property.name:
		"resource_local_to_scene":
			property.usage = PROPERTY_USAGE_NONE
		"resource_name":
			property.usage = PROPERTY_USAGE_STORAGE
		"resource_path":
			property.usage = PROPERTY_USAGE_STORAGE
