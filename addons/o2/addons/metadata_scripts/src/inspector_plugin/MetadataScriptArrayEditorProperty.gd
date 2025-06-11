extends EditorProperty

const InspectorPlugin := O2.Helpers.Editor.InspectorPlugin
const H := O2.Helpers
const C := H.Controls
const METADATA_SCRIPTS_ICON = preload("uid://cm3wwdg8y3x7m")
var inspector_plugin : InspectorPlugin
var metadata_scripts : Array[MetadataScript]
var drag_drop_parent := VBoxContainer.new()
var is_dragging := false
var array_panel := PanelContainer.new()
var heading_button := Button.new()

func _ready() -> void:
	deletable = true
	var inspector := EditorInterface.get_inspector()
	inspector.property_deleted.connect(_on_deleted)
	var object := get_edited_object()
	metadata_scripts = MetadataScript.get_metadata_scripts(get_edited_object())
	theme_type_variation = "sub_inspector_bg1"

	for p in get_property_list():
		print(p.name)



	# add_theme_stylebox_override(
	# 	"panel",
	# 	get_theme_stylebox("sub_inspector_bg1", &"EditorStyles")
	# )
	# var heading_hbox := C.create_hbox(0)

	# 3 button setup ehhh
	# var add_script_button := inspector_plugin.butt
	# var heading_add_button : MenuButton = inspector_plugin.create_metadata_script_popup_button(object)
	# heading_add_button.icon = METADATA_SCRIPTS_ICON
	# heading_add_button.text = "New Metadata Script"
	# heading_add_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	# heading_hbox.add_child(heading_add_button)
	# var load_button := Button.new()
	# InspectorPlugin.style_inspector_button(load_button, "Load")
	# heading_hbox.add_child(load_button)
	# var edit_array_button := Button.new()
	# InspectorPlugin.style_inspector_button(edit_array_button, "GuiDropdown")
	# heading_hbox.add_child(edit_array_button)
	# edit_array_button.pressed.connect(_toggle_array_panel)

	# one button setup but... seems like collapse jsut... doesn't work?
	# heading_button.text = "Edit"
	# heading_button.icon = METADATA_SCRIPTS_ICON
	# heading_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	# heading_button.pressed.connect(_toggle_array_panel)
	# heading_hbox.add_child(heading_button)
	# InspectorPlugin.style_inspector_button(heading_button)
	# heading_hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	# add_child(heading_hbox)
	add_child(array_panel)
	# array_panel.hide()

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
		var resource_editor : EditorResourcePicker = O2.Helpers.Nodes.get_descendents_with_type(ep, EditorResourcePicker)[0]
		resource_editor.edited_resource = script
		ep.update_property()

		var up_button := O2.Helpers.Editor.InspectorPlugin.style_inspector_button(Button.new(), "MoveUp")
		C.v_expand_fill(up_button)
		up_button.pressed.connect(_move_up.bind(i))

		var drag_button := O2.Helpers.Editor.InspectorPlugin.style_inspector_button(Button.new(), "TripleBar")
		C.v_expand_fill(drag_button)
		drag_button.set_drag_forwarding(
			_drag_index.bind(hbox),
			_can_drop_index.bind(hbox),
			_drop_index.bind(hbox),
		)
		hbox.set_drag_forwarding(
			Callable(),
			_can_drop_index.bind(hbox),
			Callable(),
		)

		var down_button := O2.Helpers.Editor.InspectorPlugin.style_inspector_button(Button.new(), "MoveDown")
		down_button.pressed.connect(_move_down.bind(i))
		C.v_expand_fill(down_button)

		var btn_vbox := C.create_vbox_with_children([up_button, drag_button, down_button])
		C.v_expand_fill(C.h_expand_fill(btn_vbox))
		btn_vbox.alignment = BoxContainer.ALIGNMENT_CENTER

		up_button.hide()
		down_button.hide()

		if i == 0:
			up_button.hide()
		if i == metadata_scripts.size() - 1:
			down_button.hide()

		var delete_button := O2.Helpers.Editor.InspectorPlugin.style_inspector_button(Button.new(), "Close")
		delete_button.pressed.connect(_remove.bind(script))

		hbox.add_child(btn_vbox)
		hbox.add_child(ep)
		hbox.add_child(delete_button)
		drag_drop_parent.add_child(hbox)
		if array_panel.visible:
			set_bottom_editor(array_panel)

	var add_button : MenuButton = inspector_plugin.create_metadata_script_popup_button(object)
	add_button.icon = null
	add_button.add_theme_icon_override("icon", inspector.get_theme_icon("Add", &"EditorIcons"))
	var cc := CenterContainer.new()
	cc.add_child(add_button)
	vbox.add_child(cc)

func _toggle_array_panel() -> void:
	array_panel.visible = !array_panel.visible
	if array_panel.visible:
		set_bottom_editor(array_panel)
	else:
		set_bottom_editor(null)

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
		prints("set", property, value)
		var i := property.to_int()
		var md_scripts : Array[MetadataScript] = object.get_meta("metadata_scripts")
		md_scripts[i] = value
		return true