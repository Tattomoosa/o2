@tool
@icon("uid://cm3wwdg8y3x7m")
abstract class_name MetadataScript
extends Resource

var node : Node:
	set(v):
		if node == v:
			return
		assert(node == null, "Node can only be set once!")
		node = v
		_setup(v)

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
	return object.has_meta(METADATA_SCRIPTS_PROPERTY)

static func get_metadata_scripts(object: Object) -> Array[MetadataScript]:
	if !has_metadata_scripts(object):
		return []
	return object.get_meta(METADATA_SCRIPTS_PROPERTY)

func add_to_node(p_node: Node) -> void:
	assert(p_node and is_instance_valid(p_node), "Invalid node!")
	assert(!node, "Already attached to a node %s" % node)
	if !has_metadata_scripts(p_node):
		p_node.set_meta(METADATA_SCRIPTS_PROPERTY, [] as Array[MetadataScript])
	var md_scripts := get_metadata_scripts(p_node)
	if !resource_local_to_scene:
		push_warning("%s is not local to scene! Call super() in _init()! Attaching duplicate to %s." % [self, node])
		md_scripts.push_back(self.duplicate())
	else:
		md_scripts.push_back(self)
	_setup(p_node)

func _setup(p_node: Node) -> void:
	node = p_node
	if !node.tree_entered.is_connected(_enter_tree):
		node.tree_entered.connect(_enter_tree)
	if !node.tree_exiting.is_connected(_exit_tree):
		node.tree_exiting.connect(_exit_tree)
	if !node.ready.is_connected(_ready):
		node.ready.connect(_ready)

func _validate_property(property: Dictionary) -> void:
	match property.name:
		"resource_local_to_scene":
			property.usage = PROPERTY_USAGE_NONE
		"resource_name":
			property.usage = PROPERTY_USAGE_STORAGE
		"resource_path":
			property.usage = PROPERTY_USAGE_STORAGE