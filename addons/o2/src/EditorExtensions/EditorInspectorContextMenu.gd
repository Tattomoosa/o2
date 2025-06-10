@tool
extends O2.Helpers.Editor.InspectorPlugin

const CONTEXT_MENU_ICON := preload("uid://cwkhdjneks2ad")
var context_menu_items := [
	{
		"name": "Print Property Info",
		"callable": _print_property_info
	},
	{
		"name": "Print Editor Property Tree",
		"callable": _print_editor_property_tree
	}
]

func _can_handle(_object: Object) -> bool:
	return true

func _parse_end(_object: Object) -> void:
	var inspector := EditorInterface.get_inspector()
	var properties := O2.Helpers.Nodes.get_descendents_with_type(
		inspector,
		EditorProperty,
		true
	)
	for property in properties:
		if property.has_meta("is_patched"):
			return
		_add_context_menu(property)
		property.set_meta("is_patched", true)

func _add_context_menu(ep: EditorProperty) -> void:
	var property := O2.Helpers.PropertyInfo.get_property(ep.get_edited_object(), ep.get_edited_property())

	var button := MenuButton.new()
	button.flat = true
	button.icon = CONTEXT_MENU_ICON
	button.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
	button.add_theme_color_override("icon_normal_color", Color(Color.WHITE, 0.2))
	button.tooltip_text = "More Options..."
	button.expand_icon = false

	var in_bottom_editor := property_is_in_bottom_editor(property)
	in_bottom_editor = false
	ep.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if !in_bottom_editor:
		var hbox := HBoxContainer.new()
		var parent := ep.get_parent()
		var index := ep.get_index()
		ep.reparent(hbox)
		parent.add_child(hbox)
		parent.move_child(hbox, index)
		var vbox := VBoxContainer.new()
		vbox.add_child(button)
		# hbox.add_child(vbox, false, Node.INTERNAL_MODE_FRONT)
		hbox.add_child(vbox)
	else:
		# TODO adjust for bottom editor properly
		if ep.get_child_count() == 1:
			ep.name_split_ratio = 1.0
			ep.add_child(button)
		else:
			ep.print_tree_pretty()
			var hbox := HBoxContainer.new()
			hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			for i in ep.get_children().size():
				if i == 0:
					continue
				var child := ep.get_child(i)
				child.reparent(hbox)
				child.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			hbox.add_child(button)
			ep.add_child(hbox, false, Node.INTERNAL_MODE_BACK)
	
	var popup := button.get_popup()
	if ep.has_meta(CONTEXT_MENU_META_PROPERTY_NAME):
		var meta_items : Array = ep.get_meta(CONTEXT_MENU_META_PROPERTY_NAME)
		for item in meta_items:
			popup.add_item(item.name)
		# popup.add_separator("", -1)
	for item in context_menu_items:
		popup.add_item(item.name)
	popup.index_pressed.connect(_on_popup_pressed.bind(ep))

func _on_popup_pressed(index: int, ep: EditorProperty) -> void:
	var menu_items := []
	if ep.has_meta(CONTEXT_MENU_META_PROPERTY_NAME):
		menu_items.append_array(ep.get_meta(CONTEXT_MENU_META_PROPERTY_NAME))
	menu_items.append_array(context_menu_items)
	menu_items[index].callable.call(ep)

func _print_property_info(ep: EditorProperty) -> void:
	var property := O2.Helpers.PropertyInfo.get_property(ep.get_edited_object(), ep.get_edited_property())
	print(O2.Helpers.PropertyInfo.prettify(property))

func _print_editor_property_tree(ep: EditorProperty) -> void:
	ep.print_tree_pretty()