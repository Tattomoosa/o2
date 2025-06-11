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
var label_text : String
var expand_text : String

var drag_drop_parent := VBoxContainer.new()
var array_panel := PanelContainer.new()
var expand_button := Button.new()
var heading_hbox := HBoxContainer.new()
var add_button := Button.new()

# Needs extended
func _get_editor_property(_array: Array, _index: int) -> EditorProperty:
	return EditorProperty.new()

# Needs extended
func _get_add_button() -> Button:
	var btn := Button.new()
	btn.text = "Add Item"
	btn.add_theme_icon_override("icon", EditorInterface.get_inspector().get_theme_icon("Add", &"EditorIcons"))
	return btn

func _ready() -> void:
	var inspector := EditorInterface.get_inspector()
	inspector.property_deleted.connect(_on_deleted)
	var object := get_edited_object()
	fake_resource_holder.object = object
	fake_resource_holder.array = array

	name_split_ratio = 0.5
	if label_text:
		label = label_text
	# TODO howwww to color the thing
	# might need to custom control :(
	# theme_type_variation = "sub_inspector_bg1"

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
		var item_row_hbox := HBoxContainer.new()
		item_row_hbox.size_flags_horizontal = SIZE_EXPAND_FILL

		var ep := _get_editor_property(array, i)
		ep.name_split_ratio = 0.5
		ep.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		ep.label = str(i)
		ep.update_property()

		var up_button := H.Editor.InspectorPlugin.style_inspector_button(Button.new(), "MoveUp")
		up_button.pressed.connect(_move_up.bind(i))
		if i == 0: up_button.hide()

		var drag_button := H.Editor.InspectorPlugin.style_inspector_button(Button.new(), "TripleBar")
		drag_button.size_flags_vertical = Control.SIZE_EXPAND_FILL
		drag_button.set_drag_forwarding(_drag_index.bind(item_row_hbox), _can_drop_index.bind(item_row_hbox), _drop_index.bind(item_row_hbox))
		item_row_hbox.set_drag_forwarding(Callable(), _can_drop_index.bind(item_row_hbox), Callable())

		var down_button := H.Editor.InspectorPlugin.style_inspector_button(Button.new(), "MoveDown")
		down_button.pressed.connect(_move_down.bind(i))
		if i == array.size() - 1: down_button.hide()

		up_button.hide()
		down_button.hide()

		var delete_button := H.Editor.InspectorPlugin.style_inspector_button(Button.new(), "Close")
		delete_button.pressed.connect(_remove.bind(item_row_hbox))
		delete_button.size_flags_vertical = Control.SIZE_EXPAND_FILL

		var btn_vbox := C.create_vbox_with_children([up_button, drag_button, down_button])
		C.v_expand_fill(C.h_expand_fill(btn_vbox))
		var delete_btn_vbox := C.create_vbox_with_children([delete_button])
		delete_btn_vbox.alignment = BoxContainer.ALIGNMENT_CENTER

		item_row_hbox.add_child(btn_vbox)
		item_row_hbox.add_child(ep)
		item_row_hbox.add_child(delete_btn_vbox)

		drag_drop_parent.add_child(item_row_hbox)
		if array_panel.visible:
			set_bottom_editor(array_panel)

		for b in [delete_button, up_button, down_button, drag_button]:
			_update_button_size.call_deferred(b, ep.size.y)

	add_button = _get_add_button()

	var end_button_hbox := VBoxContainer.new()
	end_button_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	end_button_hbox.add_child(add_button)

	var cc := CenterContainer.new()
	cc.add_child(end_button_hbox)

	panel_vbox.add_child(cc)

func _update_button_size(b: Button, y: int) -> void:
	b.custom_minimum_size.y = y

func _toggle_array_panel() -> void:
	array_panel.visible = !array_panel.visible
	if array_panel.visible:
		set_bottom_editor(array_panel)
	else:
		set_bottom_editor(null)

func _delete_all() -> void:
	array.clear()
	get_edited_object().notify_property_list_changed()

func _remove(row: HBoxContainer) -> void:
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
	pass

func _drag_index(_pos: Vector2, draggable: Control) -> Variant:
	is_dragging = true
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	return draggable

func _drop_index(_pos: Vector2, _data: Variant, _draggable: Control) -> void:
	var index := 0
	for item in drag_drop_parent.get_children():
		var ep := H.Nodes.get_first_child_with_type(item, EditorProperty)
		ep.label = str(index)
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
	if data is HBoxContainer:
		var d := draggable if draggable is not Button else draggable.get_parent()
		if data.get_parent() != draggable.get_parent():
			return false
		var drag_index : int = data.get_index()
		var drop_index : int = draggable.get_index()
		if drag_index != drop_index:
			var p := d.get_parent()
			p.move_child(data, drop_index)
		return true
	return false

# TODO move a bunch of stuff here!
class ArrayItem extends HBoxContainer:
	pass

class FakeArray extends RefCounted:
	var object : Object
	var array : Array

	func _get(property: StringName) -> Variant:
		var i := property.to_int()
		return array[i]

	func _set(property: StringName, value: Variant) -> bool:
		var i := property.to_int()
		# var md_scripts : Array[MetadataScript] = object.get_meta("metadata_scripts")
		# md_scripts[i] = array
		array[i] = value
		return true