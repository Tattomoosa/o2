static var scene_root : Node = null

func _init() -> void:
	assert("This is a static class and can't be instantiated")

static func get_first_child_with_type(node: Node, type: Variant, include_internal := false) -> Node:
	for child in node.get_children(include_internal):
		if is_instance_of(child, type):
			return child
	return null

static func get_first_parent_with_type(node: Node, type: Variant) -> Node:
	var parent := node.get_parent()
	if !parent:
		return null
	if is_instance_of(parent, type):
		return parent
	return get_first_parent_with_type(parent, type)

static func get_children_with_type(node: Node, type: Variant, include_internal := false) -> Array[Node]:
	var type_children : Array[Node] = []
	for child in node.get_children(include_internal):
		if is_instance_of(child, type):
			type_children.push_back(child)
	return type_children

static func queue_free_children(node: Node, include_internal := false) -> void:
	for child in node.get_children(include_internal):
		child.queue_free()

static func get_next_sibling(node: Node) -> Node:
	var index := node.get_index()
	return node.get_parent().get_child(index + 1)

static func is_scene_root(node: Node) -> bool:
	if scene_root:
		return scene_root == node
	return node.get_tree().current_scene == node

static func get_children_recursive(node: Node) -> Array[Node]:
	var arr : Array[Node] = []
	for child in node.get_children():
		arr.append(child)
		arr.append_array(get_children_recursive(child))
	return arr

static func get_children_with_type_recursive(node: Node, type: Variant) -> Array[Node]:
	var arr : Array[Node] = []
	for child in node.get_children():
		if is_instance_of(child, type):
			arr.append(child)
		arr.append_array(get_children_recursive(child))
	return arr

static func get_children_reversed(node: Node, include_internal := false) -> Array[Node]:
	var children := node.get_children(include_internal)
	children.reverse()
	return children

static func get_child_count_recursive(node: Node) -> int:
	var count := 1
	for child in node.get_children():
		count += get_child_count_recursive(child)
	return count