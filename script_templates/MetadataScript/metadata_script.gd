# meta-name: Metadata Script
# meta-description: Basic template for creating a new metadata script
# meta-default: true
@tool
extends MetadataScript

# The rules:
# Have to call super() in _init
# Use add_to_node(node) if the node is already in the tree
# Duplicate nodes with DUPLICATE_USE_INSTANTIATION only... probably
# Have fun!

func _init() -> void:
	super()

func _enter_tree() -> void:
	pass

func _ready() -> void:
	pass

func _exit_tree() -> void:
	pass

static func can_attach_to(_node: Node) -> bool:
	return true