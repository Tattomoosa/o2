@tool
extends Tree

signal updated_entries(entries: int)

@export var updates_per_frame := 500
@export var wait_between_updates := 2.0
const METADATA_NODE_NAME = 0

var all_nodes := PackedStringArray()
var search_match_highlight : Color
var updates_this_frame := 0
var updated_this_update := 0
var updated_last_update := 0
var updating := false
var filtering := false

@onready var update_progress := %UpdateProgress

func _ready() -> void:
	search_match_highlight = EditorInterface.get_editor_theme().get_color("accent_color", "Editor")
	search_match_highlight.a = 0.4
	add_theme_stylebox_override(&"panel", EditorInterface.get_editor_theme().get_stylebox("Background", "EditorStyles"))
	visibility_changed.connect(update)

func update() -> void:
	if updating: return
	if filtering: return
	if !visible: return
	if is_part_of_edited_scene(): return
	updating = true
	updated_this_update = 0
	update_progress.modulate.a = 0.2
	all_nodes.clear()

	var root := get_tree().root
	if root == null:
		clear()
		return
	var root_view := get_root()
	if root_view == null:
		root_view = _create_node_view(root, null, false)
	await _update_branch(root, root_view)
	updating = false

	updated_last_update = updated_this_update
	updated_entries.emit(updated_this_update)
	update_progress.modulate.a = 0.0
	await get_tree().create_timer(wait_between_updates).timeout
	update.call_deferred()

func _update_branch(root_node: Node, root_item: TreeItem) -> void:
	# if root_view.collapsed and root_view.get_first_child() != null:
	# 	# Don't care about collapsed nodes.
	# 	# The editor is a big tree, don't waste cycles on things you can't see
	# 	#print(root, " is collapsed and first child is ", root_view.get_first_child())
		# return

	updates_this_frame += 1
	updated_this_update += 1
	if updates_this_frame > updates_per_frame:
		update_progress.value = inverse_lerp(0, updated_last_update, updated_this_update)
		await get_tree().process_frame
		updates_this_frame = 0
	

	if !root_node or !is_instance_valid(root_node):
		root_item.get_parent().remove_child(root_item)
		return

	all_nodes.push_back(root_node.name + ":" + H.Scripts.get_class_name_or_script_name(root_node))
	var child_items := root_item.get_children()

	var non_internal_children := root_node.get_children()	
	for i in root_node.get_child_count(true):
		var child := root_node.get_child(i, true)
		var internal := child not in non_internal_children
		var child_item: TreeItem
		if i >= len(child_items):
			child_item = _create_node_view(child, root_item, internal)
			child_items.append(child_item)
		else:
			child_item = child_items[i]
			var child_view_name: String = child_item.get_metadata(METADATA_NODE_NAME)
			if child.name != child_view_name:
				_update_node_view(child, child_item, internal)
		await _update_branch(child, child_item)
	
	# Remove excess tree items
	if root_node.get_child_count(true) < len(child_items):
		for i in range(root_node.get_child_count(true), len(child_items)):
			child_items[i].free()

func _create_node_view(node: Node, parent_view: TreeItem, internal: bool) -> TreeItem:
	assert(node is Node)
	assert(parent_view == null or parent_view is TreeItem)
	var view := create_item(parent_view)
	view.collapsed = true
	_update_node_view(node, view, internal)
	return view

func _update_node_view(node: Node, view: TreeItem, internal: bool) -> void:
	assert(node is Node)
	assert(view is TreeItem)
	
	var icon_texture := H.Editor.IconGrabber.get_class_icon(H.Scripts.get_class_name_or_script_name(node), "Node")
	
	view.set_icon(0, icon_texture)
	var c_name := H.Scripts.get_class_name_or_script_name(node)
	var node_name := &"" if "@" in node.name else node.name
	var display_text := '"%s" (%s)' % [node_name, c_name] if node_name else c_name
	view.set_text(0, display_text)
	if internal:
		view.set_custom_color(0, Color(Color.WHITE, 0.4))
	
	view.set_metadata(METADATA_NODE_NAME, node.name)

func focus_node(node: Node) -> void:
	var parent: Node = get_tree().root
	var path := node.get_path()
	var parent_view := get_root()
	
	var node_view: TreeItem = null
	
	for i in range(1, path.get_name_count()):
		var part := path.get_name(i)
		print(part)
		
		var child_view := parent_view.get_first_child()
		if child_view == null:
			_update_branch(parent, parent_view)
		
		child_view = parent_view.get_first_child()
		
		while child_view != null and child_view.get_metadata(METADATA_NODE_NAME) != part:
			child_view = child_view.get_next()
		
		if child_view == null:
			node_view = parent_view
			break
		
		node_view = child_view
		parent = parent.get_node(NodePath(part))
		parent_view = child_view
	
	if node_view != null:
		_uncollapse_to_root(node_view)
		node_view.select(0)
		ensure_cursor_is_visible()

func get_item_node(item: TreeItem) -> Node:
	if item.get_parent() == null:
		return get_tree().root
	
	# Reconstruct path
	var path: String = item.get_metadata(METADATA_NODE_NAME)
	var parent_view := item
	while parent_view.get_parent() != null:
		parent_view = parent_view.get_parent()
		# Exclude root
		if parent_view.get_parent() == null:
			break
		path = str(parent_view.get_metadata(METADATA_NODE_NAME), "/", path)
	
	var node := get_tree().root.get_node(path)
	return node

static func _uncollapse_to_root(node_view: TreeItem) -> void:
	var parent_view := node_view.get_parent()
	while parent_view != null:
		parent_view.collapsed = false
		parent_view = parent_view.get_parent()

func collapse_except_selected() -> void:
	var selected := get_selected()
	print(selected)
	get_root().set_collapsed_recursive(true)
	print(selected)
	if selected:
		selected.uncollapse_tree()
		set_selected(selected, 0)