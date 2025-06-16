@tool
class_name Splitter
extends SplitContainer

signal can_close(value: bool)

const Splitter := preload("Splitter.gd")

var stashed_children : Array[Node] = []

func _ready() -> void:
	if Engine.is_editor_hint() and !is_part_of_edited_scene():
		add_theme_stylebox_override(&"split_bar_background", EditorInterface.get_editor_theme().get_stylebox("Background", &"EditorStyles"))
	can_close.emit(get_parent() is Splitter)

func close() -> void:
	var parent := get_parent()
	if parent is not Splitter:
		push_error("Close aborted: Non-Splitter parent.")
		return
	if parent.get_child_count() > 2:
		push_error("Close aborted: Parent %s has more than 2 children. (%d)" % [parent, parent.get_child_count()])
		return
	var splitter0 := parent.get_child(0)
	var splitter1 := parent.get_child(1)
	for child in parent.get_children():
		parent.remove_child(child)
	parent._unstash_children()
	_swap_unowned_children(splitter0, parent)
	_swap_unowned_children(splitter1, parent)
	splitter0.queue_free()
	splitter1.queue_free()

func split_horizontal() -> void:
	split()

func split_vertical() -> void:
	split(true)

func split(p_vertical := false) -> void:
	vertical = p_vertical
	var scene : PackedScene = load(scene_file_path)

	# first child takes any children that don't belong to the scene
	var child_splitter0 : Splitter = scene.instantiate()
	_swap_unowned_children(self, child_splitter0)
	_stash_children()
	add_child(child_splitter0)

	var child_splitter1 : Splitter = scene.instantiate()
	add_child(child_splitter1)

func _stash_children() -> void:
	assert(stashed_children.is_empty())
	stashed_children = get_children()
	for child in stashed_children:
		remove_child(child)

func _unstash_children() -> void:
	for child in stashed_children:
		add_child(child)
		var descendents := H.Nodes.get_descendents(child)
		for d in descendents: d.owner = self
	stashed_children = []

static func _swap_unowned_children(from: Splitter, to: Splitter) -> void:
	var parent_stack : Array[Node] = [from]
	var new_parent_stack : Array[Node] = [to]
	while parent_stack.size():
		var parent : Node = parent_stack.pop_front()
		var new_parent : Node = new_parent_stack.pop_front()
		var to_reparent : Array[Node] = []
		for i in parent.get_child_count():
			var child := parent.get_child(i)
			if child.owner != from:
				to_reparent.push_back(child)
			else:
				parent_stack.push_back(child)
				new_parent_stack.push_back(new_parent.get_child(i))
		for child in to_reparent:
			parent.remove_child(child)
			child.owner = null
			new_parent.add_child(child, true)
			child.owner = new_parent

func get_unowned_children(from: Splitter = self) -> Array[Node]:
	var parent_stack : Array[Node] = [from]
	var unowned_children : Array[Node] = []
	while parent_stack.size():
		var parent : Node = parent_stack.pop_front()
		for i in parent.get_child_count():
			var child := parent.get_child(i)
			if child.owner != from:
				if child.owner == child and child is Splitter:
					unowned_children.append_array(get_unowned_children(child))
				else:
					unowned_children.push_back(child)
			else:
				parent_stack.push_back(child)
	return unowned_children

func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	if !scene_file_path:
		warnings.push_back("Splitter.gd must be the scene root to function correctly")
	return warnings
