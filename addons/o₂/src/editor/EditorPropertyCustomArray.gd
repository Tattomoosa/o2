extends EditorProperty

# TODO probably lots to clean up here
# maybe needs a paginator like the native one?
# idk

const InspectorPlugin := H.Editor.InspectorPlugin
const C := H.Controls

static var state : Dictionary

var use_custom_delete_button := false

var inspector_plugin : InspectorPlugin
var fake_resource_holder := FakeArray.new()
var array : Array = []
var is_dragging := false
var button_icon : Texture2D
var show_size := true

var instance_state : Dictionary

var drag_drop_parent := VBoxContainer.new()
var array_panel := PanelContainer.new()
var expand_button := Button.new()
var heading_hbox := HBoxContainer.new()
var add_button : Control = Button.new()


# Needs extended
func _get_editor_property(_index: int) -> EditorProperty:
	return EditorProperty.new()


# Needs extended
func _get_add_button() -> Control:
	var btn := Button.new()
	btn.text = "Add Item"
	btn.add_theme_icon_override("icon", EditorInterface.get_inspector().get_theme_icon("Add", &"EditorIcons"))
	return btn


func _ready() -> void:
	_load_instance_state()
	var inspector := EditorInterface.get_inspector()
	inspector.property_deleted.connect(_on_deleted)
	var object := get_edited_object()
	fake_resource_holder.object = object
	fake_resource_holder.array = array

	add_child(heading_hbox)
	add_child(array_panel)

	# Expand Button
	expand_button.text = "%s (size %s)" % ["Array", array.size()]
	expand_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	InspectorPlugin.style_inspector_button(expand_button)
	expand_button.pressed.connect(_toggle_array_panel)
	heading_hbox.add_child(expand_button)

	# Delete Button (if custom needed)
	if use_custom_delete_button:
		deletable = false
		var delete_array_button := Button.new()
		InspectorPlugin.style_inspector_button(delete_array_button, "Close")
		delete_array_button.flat = true
		delete_array_button.pressed.connect(_delete_all)
		heading_hbox.add_child(delete_array_button)

	var panel_vbox := VBoxContainer.new()
	panel_vbox.size_flags_horizontal = SIZE_EXPAND_FILL
	array_panel.add_child(panel_vbox)
	panel_vbox.add_child(drag_drop_parent)

	for i in array.size():
		var item_row := ArrayItem.new()
		# item_row.index = i
		item_row.editor_property = _get_editor_property(i)
		item_row.array = array

		item_row.drag_button.set_drag_forwarding(
			_drag_index.bind(item_row),
			_can_drop_index.bind(item_row),
			_drop_index.bind(item_row)
		)
		item_row.set_drag_forwarding(Callable(), _can_drop_index.bind(item_row), Callable())
		item_row.deleted.connect(_remove)

		drag_drop_parent.add_child(item_row)

	add_button = _get_add_button()

	var end_button_hbox := VBoxContainer.new()
	end_button_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	end_button_hbox.add_child(add_button)

	var cc := CenterContainer.new()
	cc.add_child(end_button_hbox)

	panel_vbox.add_child(cc)
	if !instance_state.collapsed:
		set_bottom_editor(array_panel)
	else:
		array_panel.hide()


func _load_instance_state():
	instance_state = state.get_or_add(get_edited_object(), {}).get_or_add(get_edited_property(), {})
	if "collapsed" not in instance_state:
		instance_state.collapsed = true


func _toggle_array_panel() -> void:
	instance_state.collapsed = !instance_state.collapsed
	array_panel.visible = !instance_state.collapsed
	if array_panel.visible:
		array_panel.show()
		set_bottom_editor(array_panel)
	else:
		array_panel.hide()
		set_bottom_editor(null)


func _delete_all() -> void:
	array.clear()
	get_edited_object().notify_property_list_changed()


func _remove(row: ArrayItem) -> void:
	array.remove_at(row.get_index())
	get_edited_object().notify_property_list_changed()


func _move_up(i: int) -> void:
	var object := get_edited_object()
	H.Arrays.swap(array, i, i - 1)
	object.notify_property_list_changed()


func _move_down(i: int) -> void:
	var object := get_edited_object()
	H.Arrays.swap(array, i, i + 1)
	object.notify_property_list_changed()


func _on_deleted(property_name: String) -> void:
	if property_name == get_edited_property():
		_delete_all()


func _drag_index(_pos: Vector2, draggable: Control) -> Variant:
	is_dragging = true
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	return draggable


func _drop_index(_pos: Vector2, _data: Variant, _draggable: Control) -> void:
	var index := 0
	for item in drag_drop_parent.get_children():
		item.editor_property.label = str(index)
		index += 1
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	is_dragging = false


func _notification(notification_type):
	match notification_type:
		NOTIFICATION_DRAG_END:
			if !is_dragging:
				return
			_drop_index(Vector2.ZERO, null, null)


func _can_drop_index(_pos: Vector2, data: Variant, draggable: Control) -> bool:
	if data is not ArrayItem:
		return false
	var d := draggable if draggable is not Button else draggable.get_parent().get_parent()
	if data.get_parent() != draggable.get_parent():
		return false
	var drag_index : int = data.get_index()
	var drop_index : int = draggable.get_index()
	if drag_index != drop_index:
		var p := d.get_parent()
		p.move_child(data, drop_index)
	return true


class ArrayItem extends PanelContainer:

	signal move_up
	signal move_down
	signal deleted

	# need set
	var editor_property : EditorProperty
	var show_up_down_buttons : bool = false
	var array : Array

	var up_button : Button
	var down_button : Button
	var drag_button : Button


	func _init() -> void:
		drag_button = H.Editor.InspectorPlugin.style_inspector_button(Button.new(), "TripleBar")
		drag_button.size_flags_vertical = Control.SIZE_EXPAND_FILL
	

	func _update_index() -> void:
		var index := get_index()
		self_modulate = Color(0.8, 0.8, 0.8) if index % 2 == 1 else Color.WHITE
		editor_property.label = str(index)
		if show_up_down_buttons:
			up_button.visible = index != 0
			down_button.visible = index < get_parent().get_child_count() - 1
		else:
			up_button.hide()
			down_button.hide()


	func _ready() -> void:
		get_parent().child_order_changed.connect(_update_index)
		add_theme_stylebox_override(
			"panel",
			get_theme_stylebox("PanelForeground", &"EditorStyles")
		)

		var hbox := HBoxContainer.new()
		hbox.size_flags_horizontal = SIZE_EXPAND_FILL
		add_child(hbox)

		editor_property.name_split_ratio = 0.5
		editor_property.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		editor_property.update_property()

		up_button = H.Editor.InspectorPlugin.style_inspector_button(Button.new(), "MoveUp")
		up_button.pressed.connect(_move_up)

		down_button = H.Editor.InspectorPlugin.style_inspector_button(Button.new(), "MoveDown")
		down_button.pressed.connect(_move_down)

		if !show_up_down_buttons:
			up_button.hide()
			down_button.hide()

		var delete_button := H.Editor.InspectorPlugin.style_inspector_button(Button.new(), "Close")
		delete_button.pressed.connect(deleted.emit.bind(self))
		delete_button.size_flags_vertical = Control.SIZE_EXPAND_FILL

		var btn_vbox := C.create_vbox_with_children([up_button, drag_button, down_button])
		C.v_expand_fill(C.h_expand_fill(btn_vbox))
		var delete_btn_vbox := C.create_vbox_with_children([delete_button])
		delete_btn_vbox.alignment = BoxContainer.ALIGNMENT_CENTER

		hbox.add_child(btn_vbox)
		hbox.add_child(editor_property)
		hbox.add_child(delete_btn_vbox)
	

	func _move_up() -> void:
		move_up.emit(get_index())


	func _move_down() -> void:
		move_down.emit(get_index())


class FakeArray extends RefCounted:
	var object : Object
	var array : Array


	func _get(property: StringName) -> Variant:
		var i := property.to_int()
		return array[i]


	func _set(property: StringName, value: Variant) -> bool:
		var i := property.to_int()
		array[i] = value
		return true