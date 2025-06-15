@tool
extends TabContainer

# TODO get from appropriate editor theme place
@export var can_drop_data_type_stylebox : StyleBox
# TODO get from appropriate editor theme place
@export var can_drop_data_now_stylebox : StyleBox
@export var no_margins := true

var _can_drop_data_type := false
var _can_drop_data_now := false
var _can_drop_data_type_stylebox : StyleBox
var _panel : StyleBox

func _ready() -> void:
	_panel = get_theme_stylebox("panel", "TabContainer")
	if no_margins:
		add_theme_constant_override("side_margin", 0)
	_can_drop_data_type_stylebox = _get_can_drop_data_stylebox()
	child_exiting_tree.connect(_child_exiting_tree)
	mouse_exited.connect(queue_redraw)
	if !get_child_count():
		queue_redraw()

func _child_exiting_tree(child: Node) -> void:
	await child.tree_exited
	queue_redraw()

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_DRAG_BEGIN:
			# also queues redraw
			_can_drop_data(Vector2.ZERO, get_viewport().gui_get_drag_data())
		NOTIFICATION_DRAG_END:
			if !get_child_count():
				_can_drop_data_type = false
				_can_drop_data_now = false
				queue_redraw()

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	if get_child_count(): # not empty
		return false
	if tabs_rearrange_group == -1:
		return false
	if not ("type" in data and data.type is String and data.type == "tab_container_tab"):
		return false
	var from_tab_bar : TabBar = get_node(data.from_path)
	if from_tab_bar.tabs_rearrange_group != tabs_rearrange_group:
		return false
	var node := from_tab_bar.get_parent().get_child(data.tab_index)
	var parent := get_parent()
	while parent:
		if parent == node:
			return false
		parent = parent.get_parent()
	_can_drop_data_type = true
	_can_drop_data_now = get_rect().has_point(at_position)
	queue_redraw()
	return true

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	var tab_bar : TabBar = get_node(data.from_path)
	var node := tab_bar.get_parent().get_child(data.tab_index)
	node.reparent(self)
	_can_drop_data_now = false

func _get_can_drop_data_stylebox() -> StyleBox:
	if Engine.is_editor_hint() and !is_part_of_edited_scene():
		return EditorInterface.get_inspector().get_theme_stylebox("Focus", "EditorStyles")
	return can_drop_data_type_stylebox

func _draw() -> void:
	if get_child_count():
		return
	var rect := get_rect()
	var tab_bar := get_tab_bar()

	if tab_bar.visible:
		rect.position -= position

	# margins, lets just assume margin empty lol
	# var margin := _panel.content_margin_top
	# rect.position += Vector2(margin, 0)
	# rect.size -= Vector2.ONE * margin

	if !_can_drop_data_now:
		var empty_bg := get_theme_stylebox("tabbar_background", "TabContainer")
		draw_style_box(empty_bg, rect)

	if _can_drop_data_type:
		# null for one frame for some reason?
		if _can_drop_data_type_stylebox:
			draw_style_box(_can_drop_data_type_stylebox, rect)
