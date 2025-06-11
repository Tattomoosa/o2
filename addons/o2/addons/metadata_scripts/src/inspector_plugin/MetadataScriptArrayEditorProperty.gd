extends EditorProperty
# TODO extends EditorPropertyCustomArray
# the generic version of this

const InspectorPlugin := H.Editor.InspectorPlugin
const C := H.Controls
const METADATA_SCRIPTS_ICON = preload("uid://cm3wwdg8y3x7m")
var inspector_plugin : InspectorPlugin
var metadata_scripts : Array[MetadataScript]
var drag_drop_parent := VBoxContainer.new()
var is_dragging := false
var array_panel := PanelContainer.new()
var expand_button := Button.new()

func _init() -> void:
	deletable = true
	use_folding = true

func _ready() -> void:
	var inspector := EditorInterface.get_inspector()
	inspector.property_deleted.connect(_on_deleted)
	var object := get_edited_object()
	name_split_ratio = 0.5
	metadata_scripts = MetadataScript.get_metadata_scripts(get_edited_object())
	label = "Metadata Scripts"

	var heading_hbox := HBoxContainer.new()

	expand_button.text = "Metadata Scripts (size %s)" % metadata_scripts.size()
	expand_button.icon = METADATA_SCRIPTS_ICON
	expand_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	InspectorPlugin.style_inspector_button(expand_button)
	expand_button.pressed.connect(_toggle_array_panel)

	heading_hbox.add_child(expand_button)

	add_child(heading_hbox)
	add_child(array_panel)

	var vbox := VBoxContainer.new()
	vbox.size_flags_horizontal = SIZE_EXPAND_FILL
	array_panel.add_child(vbox)
	vbox.add_child(drag_drop_parent)

	var property := {
		&"name": "md_script",
		&"class_name": "",
		&"type": TYPE_OBJECT,
		&"hint": PROPERTY_HINT_RESOURCE_TYPE,
		&"hint_string": "MetadataScript",
		&"usage": 6,
	}
	var fake_resource_holder := FakeArray.new()
	fake_resource_holder.object = object

	for i in metadata_scripts.size():
		var hbox := HBoxContainer.new()
		hbox.size_flags_horizontal = SIZE_EXPAND_FILL

		var script := metadata_scripts[i]
		property.name = str(i)
		var ep := inspector_plugin.instantiate_property_editor(fake_resource_holder, property, true)
		ep.name_split_ratio = 0.5
		ep.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		ep.label = str(i)
		var resource_editor : EditorResourcePicker = H.Nodes.get_descendents_with_type(ep, EditorResourcePicker)[0]
		resource_editor.edited_resource = script
		ep.update_property()

		var up_button := H.Editor.InspectorPlugin.style_inspector_button(Button.new(), "MoveUp")
		up_button.pressed.connect(_move_up.bind(i))

		var drag_button := H.Editor.InspectorPlugin.style_inspector_button(Button.new(), "TripleBar")
		drag_button.size_flags_vertical = Control.SIZE_EXPAND_FILL
		drag_button.set_drag_forwarding(_drag_index.bind(hbox), _can_drop_index.bind(hbox), _drop_index.bind(hbox))
		hbox.set_drag_forwarding(Callable(), _can_drop_index.bind(hbox), Callable())

		var down_button := H.Editor.InspectorPlugin.style_inspector_button(Button.new(), "MoveDown")
		down_button.pressed.connect(_move_down.bind(i))
		up_button.hide()
		down_button.hide()

		if i == 0:
			up_button.hide()
		if i == metadata_scripts.size() - 1:
			down_button.hide()

		var delete_button := H.Editor.InspectorPlugin.style_inspector_button(Button.new(), "Close")
		delete_button.pressed.connect(_remove.bind(script))
		delete_button.size_flags_vertical = Control.SIZE_EXPAND_FILL

		var btn_vbox := C.create_vbox_with_children([up_button, drag_button, down_button])
		C.v_expand_fill(C.h_expand_fill(btn_vbox))
		var delete_btn_vbox := C.create_vbox_with_children([delete_button])
		delete_btn_vbox.alignment = BoxContainer.ALIGNMENT_CENTER

		hbox.add_child(btn_vbox)
		hbox.add_child(ep)
		hbox.add_child(delete_btn_vbox)

		drag_drop_parent.add_child(hbox)
		if array_panel.visible:
			# _toggle_array_panel()
			set_bottom_editor(array_panel)

		for b in [delete_button, up_button, down_button, drag_button]:
			_update_button_size.call_deferred(b, ep.size.y)

	var add_button : MenuButton = inspector_plugin.create_metadata_script_popup_button(object)
	add_button.icon = null
	add_button.add_theme_icon_override("icon", inspector.get_theme_icon("Add", &"EditorIcons"))

	# var extend_button := Button.new()
	# extend_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	# extend_button.text = "Extend"
	# extend_button.icon = METADATA_SCRIPTS_ICON
	# extend_button.pressed.connect(_create_new_metadata_script)

	var end_button_hbox := VBoxContainer.new()
	# end_button_hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	end_button_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	# var spacer := Control.new()
	# spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	# end_button_hbox.add_child(spacer)

	# heading_hbox.add_child(extend_button)
	end_button_hbox.add_child(add_button)
	# end_button_hbox.add_child(extend_button)

	var cc := CenterContainer.new()
	cc.add_child(end_button_hbox)
	vbox.add_child(cc)


func _update_button_size(b: Button, y: int) -> void:
	b.custom_minimum_size.y = y

func _create_new_metadata_script() -> void:
	EditorInterface.get_script_editor().open_script_create_dialog(
		"MetadataScript",
		EditorInterface.get_current_directory()
	)

func _toggle_array_panel() -> void:
	array_panel.visible = !array_panel.visible
	if array_panel.visible:
		set_bottom_editor(array_panel)
	else:
		set_bottom_editor(null)

func _delete_all() -> void:
	var object := get_edited_object()
	object.remove_meta(get_edited_property())

func _remove(md_script: MetadataScript) -> void:
	var object := get_edited_object()
	metadata_scripts.erase(md_script)
	if metadata_scripts.is_empty():
		object.remove_meta(get_edited_property())
	object.notify_property_list_changed()

func _move_up(i: int) -> void:
	var object := get_edited_object()
	H.Arrays.swap(metadata_scripts, i, i - 1)
	object.notify_property_list_changed()

func _move_down(i: int) -> void:
	var object := get_edited_object()
	H.Arrays.swap(metadata_scripts, i, i + 1)
	object.notify_property_list_changed()

func _on_deleted(property_name: String) -> void:
	var object := get_edited_object()
	if property_name == "metadata_scripts":
		object.remove_meta(get_edited_property())
	object.notify_property_list_changed()

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

class ArrayItem extends HBoxContainer:
	pass

class FakeArray extends RefCounted:
	var object : Object

	func _get(property: StringName) -> Variant:
		var i := property.to_int()
		return object.get_meta("metadata_scripts")[i]

	func _set(property: StringName, value: Variant) -> bool:
		var i := property.to_int()
		var md_scripts : Array[MetadataScript] = object.get_meta("metadata_scripts")
		md_scripts[i] = value
		return true