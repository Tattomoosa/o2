@tool
extends EditorPlugin

const dock_splitter_scene : PackedScene = preload("src/dock_splitter.tscn")
const Splitter := preload("src/Splitter.gd")

const LEFT_SPLITTER := 0
const RIGHT_SPLITTER := 1
const BOTTOM_SPLITTER := 2
var EMPTY_STYLEBOX := StyleBoxEmpty.new()

var _dock_splitters : Array[Splitter] = []
var dump_dock : Node
var docks_parent : Node

var _docks : Dictionary[int, Node] = {}

func _enter_tree() -> void:
	if !get_parent().is_node_ready():
		await get_parent().ready
	_register_commands()
	_find_docks()
	_setup_splitters()

func _exit_tree() -> void:
	_teardown_splitters()
	_register_commands(false)

func _teardown_splitters() -> void:
	assert(!_docks.is_empty())
	_remove_side_splitter(_dock_splitters[LEFT_SPLITTER], DOCK_SLOT_LEFT_UL)
	_remove_side_splitter(_dock_splitters[RIGHT_SPLITTER], DOCK_SLOT_RIGHT_UR)

	_reparent_from_splitter_to_dock(_dock_splitters[BOTTOM_SPLITTER], _docks[DOCK_SLOT_LEFT_BL])
	remove_control_from_bottom_panel(_dock_splitters[BOTTOM_SPLITTER])

	for splitter in _dock_splitters:
		splitter.queue_free()
	_dock_splitters = []

func _setup_splitters() -> void:
	assert(!_docks.is_empty())

	if !_dock_splitters.is_empty():
		push_error("_dock_splitters is not empty! - ", _dock_splitters)
		for s in _dock_splitters:
			if is_instance_valid(s):
				s.queue_free()

	_dock_splitters = [
		dock_splitter_scene.instantiate(),
		dock_splitter_scene.instantiate(),
		dock_splitter_scene.instantiate(),
	]

	if true: # left dock
		var s := _dock_splitters[LEFT_SPLITTER]
		s.name = "SplitDock L"
		_add_side_splitter(s, DOCK_SLOT_LEFT_UL)

	if true: # right dock
		var s := _dock_splitters[RIGHT_SPLITTER]
		s.name = "SplitDock R"
		_add_side_splitter(s, DOCK_SLOT_RIGHT_UR)

	add_control_to_bottom_panel(_dock_splitters[BOTTOM_SPLITTER], "Docks")

func _get_tab_container(splitter: Splitter) -> TabContainer:
	return splitter.get_child(0).get_child(0)

func _add_side_splitter(splitter: Splitter, slot: int):
	for child in _docks[slot].get_children():
		child.reparent(_get_tab_container(splitter))
	add_control_to_dock(slot, splitter)
	_docks[slot].tabs_visible = false
	_docks[slot].add_theme_stylebox_override("panel", EMPTY_STYLEBOX)

func _remove_side_splitter(splitter: Splitter, slot: int):
	_reparent_from_splitter_to_dock(splitter, _docks[slot])
	remove_control_from_docks(splitter)
	_docks[slot].tabs_visible = true
	_docks[slot].remove_theme_stylebox_override("panel")

func _find_docks() -> void:
	var dummy_control := Control.new()
	for slot in DOCK_SLOT_MAX:
		add_control_to_dock(slot, dummy_control)
		_docks[slot] = dummy_control.get_parent()
		remove_control_from_docks(dummy_control)
	dummy_control.queue_free()

func _reparent_from_splitter_to_dock(splitter: Splitter, dock: TabContainer):
	var unowned_children = splitter.get_unowned_children(splitter)
	for child in unowned_children:
		child.reparent(dock)

func _show_real_dock_tabs(value := true) -> void:
	_docks[DOCK_SLOT_LEFT_UL].tabs_visible = value
	_docks[DOCK_SLOT_RIGHT_UR].tabs_visible = value

func _show_dock_splitter_tabs(value := true) -> void:
	_dock_splitters[LEFT_SPLITTER].get_child(0).get_child(0).tabs_visible = value
	_dock_splitters[RIGHT_SPLITTER].get_child(0).get_child(0).tabs_visible = value
	_dock_splitters[BOTTOM_SPLITTER].get_child(0).get_child(0).tabs_visible = value

func _register_commands(value := true) -> void:
	var cp := EditorInterface.get_command_palette()
	if value:
		cp.add_command("Show Dock Splitter Tabs", "dock_splitter/show_plugin_dock_tabs", _show_real_dock_tabs)
		cp.add_command("Hide Dock Splitter Tabs", "dock_splitter/hide_plugin_dock_tabs", _show_real_dock_tabs.bind(false))
		cp.add_command("Show Godot Dock Tabs", "dock_splitter/show_real_dock_tabs", _show_dock_splitter_tabs)
		cp.add_command("Hide Godot Dock Tabs", "dock_splitter/hide_real_dock_tabs", _show_dock_splitter_tabs.bind(false))
	else:
		cp.remove_command("dock_splitter/show_plugin_dock_tabs")
		cp.remove_command("dock_splitter/hide_plugin_dock_tabs")
		cp.remove_command("dock_splitter/show_real_dock_tabs")
		cp.remove_command("dock_splitter/hide_real_dock_tabs")