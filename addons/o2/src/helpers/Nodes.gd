static var scene_root : Node = null

static func get_first_child_with_type(node: Node, type: Variant, include_internal := false) -> Node:
	for child in node.get_children(include_internal):
		if is_instance_of(child, type):
			return child
	return null

static func get_first_ancestor_with_type(node: Node, type: Variant) -> Node:
	var parent := node.get_parent()
	while parent:
		if is_instance_of(parent, type):
			return parent
		parent = parent.get_parent()
	return null

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

static func get_descendents(node: Node) -> Array[Node]:
	var arr : Array[Node]
	var parent_stack : Array[Node] = [node]
	while parent_stack.size():
		var parent = parent_stack.pop_front()
		for child in parent.get_children():
			parent_stack.push_back(child)
			arr.push_back(child)
	return arr

static func get_descendents_with_type(node: Node, type: Variant) -> Array[Node]:
	var arr : Array[Node]
	var parent_stack : Array[Node] = [node]
	while parent_stack.size():
		var parent = parent_stack.pop_front()
		for child in parent.get_children():
			parent_stack.push_back(child)
			if is_instance_of(child, type):
				arr.push_back(child)
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

func _init() -> void: assert(false, "Class can't be instantiated")