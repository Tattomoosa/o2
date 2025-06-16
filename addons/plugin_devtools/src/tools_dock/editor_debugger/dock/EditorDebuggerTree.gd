@tool
extends Tree

signal updated_entries(entries: int, time: int)

@export var updates_per_frame := 500
@export var wait_between_updates := 2.0
const METADATA_NODE_NAME = 0

enum {
	VISIBILITY_BUTTON,
	INTERNAL_INDICATOR,
}

var all_nodes := PackedStringArray()
var search_match_highlight : Color
var updates_this_frame := 0
var updated_this_update := 0
var updated_last_update := 0
var updating := false
var filtering := false

@onready var update_progress := %UpdateProgress
@onready var only_controls_checkbox := %OnlyControlsCheckbox

var parent_list : Array[Node] = []

func _enter_tree() -> void:
	parent_list.clear()
	var parent := get_parent()
	while parent:
		parent_list.push_back(parent)
		parent = parent.get_parent()

# func _exit_tree() -> void:
# 	parent_list.clear()

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
	var stopwatch := H.Timing.Stopwatch.new()
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
		root_view = _create_tree_item(root, null, false)
	await _update_branch(root, root_view)

	updating = false
	updated_last_update = updated_this_update
	update_progress.modulate.a = 0.0

	updated_entries.emit(updated_this_update, stopwatch.get_elapsed())

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
			child_item = _create_tree_item(child, root_item, internal)
			child_items.append(child_item)
		else:
			child_item = child_items[i]
			var child_view_name: String = child_item.get_metadata(METADATA_NODE_NAME)
			if child.name != child_view_name:
				_update_tree_item(child, child_item, internal)
		await _update_branch(child, child_item)
	
	# Remove excess tree items
	if root_node.get_child_count(true) < len(child_items):
		for i in range(root_node.get_child_count(true), len(child_items)):
			child_items[i].free()

func _create_tree_item(node: Node, parent_item: TreeItem, internal: bool) -> TreeItem:
	assert(node is Node)
	assert(parent_item == null or parent_item is TreeItem)
	var item := create_item(parent_item)
	item.collapsed = true
	_update_tree_item(node, item, internal)
	return item

func _update_tree_item(node: Node, item: TreeItem, internal: bool) -> void:
	assert(node is Node)
	assert(item is TreeItem)
	
	var icon_texture := H.Editor.IconGrabber.get_class_icon(H.Scripts.get_class_name_or_script_name(node), "Node")
	
	item.set_icon(0, icon_texture)
	var c_name := H.Scripts.get_class_name_or_script_name(node)
	var node_name := &"" if "@" in node.name else node.name
	var display_text := '"%s" (%s)' % [node_name, c_name] if node_name else c_name

	item.clear_buttons()
	item.set_text(0, display_text)

	if internal:
		item.set_custom_color(0, Color(Color.WHITE, 0.4))
		item.add_button(0, _theme_icon("GuiSliderGrabber"), -1, true, "Internal Child")


	# last
	_update_visibility_button(node, item)

	item.set_metadata(METADATA_NODE_NAME, node.name)

func _theme_icon(icon_name: String) -> Texture2D:
	return EditorInterface.get_inspector().get_theme_icon(icon_name, "EditorIcons")

func _update_visibility_button(node: Node, item: TreeItem) -> void:
	if "visible" in node:
		var is_parent := node in parent_list
		var icon_name := "GuiVisibilityVisible" if node.visible else "GuiVisibilityHidden"
		var icon := _theme_icon(icon_name)
		var tooltip := "Toggle Visibility" if !is_parent else "Cannot Toggle Visibility of Parents"
		item.add_button(0, icon, VISIBILITY_BUTTON, is_parent, tooltip)

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

func _reset_tree(root: TreeItem = null) -> void:
	if !root:
		root = get_root()
	root.set_collapsed_recursive(true)
	for item in root.get_children():
		item.visible = true
		item.set_custom_bg_color(0, Color.TRANSPARENT)
		_reset_tree(item)

func filter(text: String, root : TreeItem = null, data := PackedStringArray([""])) -> void:
	if !text:
		_reset_tree()
		return
	if !root:
		root = get_root()
	for item in root.get_children():
		var item_text := item.get_text(0)
		data[0] = item_text
		var item_matches := false
		if false: # TODO allow selecting fuzzy search option
			var matches := H.Search.FuzzySearch.search(text, data)
			item_matches = item_text in matches
		else:
			item_matches = text.to_lower() in item_text.to_lower()
		if item_matches:
			item.visible = true
			item.set_custom_bg_color(0, search_match_highlight, true)
			item.uncollapse_tree()
			var parent := item.get_parent()
			while parent:
				parent.visible = true
				parent = parent.get_parent()
			continue
		item.visible = false
		item.set_custom_bg_color(0, Color.TRANSPARENT)
		filter(text, item, data)