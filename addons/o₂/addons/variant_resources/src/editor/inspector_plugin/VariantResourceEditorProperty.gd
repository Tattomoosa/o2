@tool
extends EditorProperty

const VariantResourceInspector := preload("VariantResourceInspector.gd")

var picker : EditorResourcePicker
var picker_button : Button
var picker_internal_hbox : HBoxContainer
var value_editor : EditorProperty
var value_editor_parent : Control
var use_bottom_editor := false
var resource_name_label : Label
var property_definition : Dictionary
var resource_class_name : String
var inspector_plugin : O2.EditorExtensions.InspectorPlugin

const Controls := H.Controls
const Scripts := H.Scripts
const ES := O2.EditorExtensions.Settings

signal using_bottom_editor(node: Node)

func _ready() -> void:
	use_bottom_editor = _should_use_bottom_editor()
	var resource := _get_resource()
	picker = get_child(0)
	picker_button = picker.get_child(0)

	var vbox := VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 0)
	value_editor_parent = vbox

	var mc := Controls.margin_container(ES.scale_int(0))

	picker_internal_hbox = HBoxContainer.new()
	picker_internal_hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var heading := Control.new()
	if resource:
		resource_class_name = H.Scripts.get_object_class_name(resource)
		if !use_bottom_editor:
			heading.custom_minimum_size.y = ES.scale * 12
			resource_name_label = Label.new()
			resource_name_label.add_theme_font_size_override("font_size", ES.scale * 10)
			resource_name_label.set_anchors_preset(PRESET_TOP_WIDE)
			resource_name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			resource_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
			resource_name_label.position.y -= ES.scale * 6
			# resource_name_label.position.x += ES.scale * 12
			resource_name_label.z_index = 1
			_update_resource_name_label_text()
			heading.add_child(resource_name_label)
			value_editor_parent.add_child(heading, Control.INTERNAL_MODE_FRONT)

		value_editor = create_value_editor()
		resource.changed.connect(_replace_value_editor)
		var margin_container := Controls.margin_container(ES.scale * 2)
		value_editor_parent.add_child(margin_container)
		margin_container.add_child(value_editor)

		if use_bottom_editor:
			var bottom_panel := PanelContainer.new()
			bottom_panel.add_child(value_editor_parent)
			value_editor_parent = bottom_panel

		# resource.property_list_changed.connect(_replace_value_editor)
	else:
		vbox.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN

	if !resource or use_bottom_editor:
		picker_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	else:
		picker_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		picker_button.expand_icon = false

	if !use_bottom_editor:
		Controls.add_children(picker_internal_hbox, [value_editor_parent, picker_button])
	else:
		add_child(value_editor_parent)
		_set_bottom_editor(value_editor_parent)

	Controls.layout({
		control = self, children = [{
			control = mc, children = [{
				control = picker, children = [{
					control = picker_internal_hbox,
					internal = Control.INTERNAL_MODE_FRONT,
					children = [picker_button]
				}],
			}],
		}],
	})

	self.child_entered_tree.connect(_subinspector_entering)
	self.child_exiting_tree.connect(_subinspector_exiting)

	picker.resource_changed.connect(_on_resource_changed)

func _set_bottom_editor(node: Node) -> void:
	set_bottom_editor(node)
	using_bottom_editor.emit(node)

func _on_resource_changed(_resource: VariantResource) -> void:
	get_edited_object().notify_property_list_changed()

func _get_resource() -> VariantResource:
	return get_edited_object().get(get_edited_property())

func _replace_value_editor() -> void:
	if !value_editor.is_visible_in_tree():
		if !value_editor.visibility_changed.is_connected(_replace_value_editor):
			value_editor.visibility_changed.connect(_replace_value_editor, CONNECT_ONE_SHOT | CONNECT_DEFERRED)
		return
	_update_resource_name_label_text()
	var new_value_editor := create_value_editor()
	var parent := value_editor.get_parent()
	parent.add_child(new_value_editor)
	parent.remove_child(value_editor)
	value_editor.free()
	value_editor = new_value_editor
	_update_resource_name_label_text()

func _create_value_editor() -> EditorProperty:
	return inspector_plugin.instantiate_default_property_editor(
		_get_resource(),
		"value"
	)

func create_value_editor() -> EditorProperty:
	var ve := _create_value_editor()
	ve.name_split_ratio = 0.0
	ve.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return ve

func _subinspector_entering(node: Node) -> void:
	if node is not EditorInspector:
		return
	value_editor_parent.hide()
	picker_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	using_bottom_editor.emit(node)

func _subinspector_exiting(node: Node) -> void:
	if node is not EditorInspector:
		return
	value_editor_parent.show()
	if use_bottom_editor:
		_set_bottom_editor(value_editor_parent)
	else:
		picker_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		using_bottom_editor.emit(null)
	value_editor.update_property()

func _update_resource_name_label_text() -> void:
	if use_bottom_editor:
		return
	var resource := _get_resource()
	if resource.resource_name:
		resource_name_label.text = resource.resource_name
		resource_name_label.modulate = Color.WHITE
	else:
		resource_name_label.text = resource_class_name
		resource_name_label.modulate = Color(Color.WHITE, 0.4)

func _property_can_revert(_property: StringName) -> bool:
	return false

func _property_get_revert(_property: StringName) -> Variant:
	return _get_resource().value

func _should_use_bottom_editor() -> bool:
	return O2.EditorExtensions.InspectorPlugin.property_is_in_bottom_editor(property_definition)