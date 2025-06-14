@tool
extends TabContainer

var tab_bar : TabBar

signal set_buttons_enabled(value: bool)

func _ready() -> void:
	tab_bar = get_tab_bar()
	tab_bar.tab_close_display_policy = TabBar.CLOSE_BUTTON_SHOW_ALWAYS
	tab_bar.set_tab_hidden(0, true)
	tab_bar.close_with_middle_mouse = true
	tab_bar.tab_close_pressed.connect(_close_tab)

func _reload() -> void:
	var node := get_child(current_tab)
	var data : Variant = get_tab_metadata(current_tab)
	if data is Node:
		var new_node = node.duplicate()
		add_child(new_node)
		move_child(new_node, current_tab)
		remove_child(node)
		node.queue_free()
	elif data is PackedScene:
		pass
	else:
		push_error("Can't reload %s" % data)

func _child_entered() -> void:
	if get_child_count() > 1:
		deselect_enabled = false
		set_buttons_enabled.emit(true)

func _child_exiting(node: Node) -> void:
	await node.tree_exited
	if get_child_count() == 1:
		get_child(0).visible = true

func _close_tab(idx: int) -> void:
	if idx == 0:
		push_error("Tab 0 cannot be closed!")
		return
	current_tab = get_previous_tab()
	get_child(idx).queue_free()

func _add_node(node: Node) -> void:
	add_child(node)
	if !node.visible:
		node.visible = true

func _dropped_data(data: Variant) -> void:
	if data is Dictionary and "type" in data and data.type == "nodes":
		var node_paths := data.nodes as Array #[NodePath]
		# for node_path in node_paths:
		var original_node := get_node(node_paths[0])
		var node := original_node.duplicate()
		_add_node(node)
		tab_bar.set_tab_metadata(node.get_index(), original_node)

