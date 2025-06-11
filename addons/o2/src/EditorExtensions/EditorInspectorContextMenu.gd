@tool
extends EditorInspectorPlugin

const CONTEXT_MENU_ICON := preload("uid://cwkhdjneks2ad")
# TODO sections?
"""
{
	object (Object): {
		property_name (String): [
			{
				&"name": String,
				&"callable": Callable
			}
		]
	},
}
"""
static var context_menu_items : Dictionary = {}
static var clipboard : Variant = null

var context_menu_property_info_items := [
	{
		"name": "Print Property Info",
		"callable": _print_property_info
	},
	{
		"name": "Print Editor Property Tree",
		"callable": _print_editor_property_tree
	},
]

func _clear_context_menu_items():
	context_menu_items.clear()

func _can_handle(_object: Object) -> bool:
	return true

func _parse_end(_object: Object) -> void:
	_parse_end_idle_frame.call_deferred()

func _parse_end_idle_frame() -> void:
	var inspector := EditorInterface.get_inspector()
	var properties := H.Nodes.get_descendents_with_type(
		inspector,
		EditorProperty,
		true
	)
	for property in properties:
		if !property.has_meta("is_context_menu_patched"):
			_add_context_menu(property)
			property.set_meta("is_context_menu_patched", true)
	context_menu_items.clear()

func _add_context_menu(ep: EditorProperty) -> void:
	var object := ep.get_edited_object()
	var property_name := ep.get_edited_property()

	var button := MenuButton.new()
	button.flat = true
	button.icon = CONTEXT_MENU_ICON
	button.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
	button.add_theme_color_override("icon_normal_color", Color(Color.WHITE, 0.2))
	button.tooltip_text = "More Options..."
	button.expand_icon = false

	ep.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var hbox := HBoxContainer.new()
	var parent := ep.get_parent()
	var index := ep.get_index()
	ep.reparent(hbox)
	parent.add_child(hbox)
	parent.move_child(hbox, index)
	var vbox := VBoxContainer.new()
	vbox.add_child(button)
	hbox.add_child(vbox)
	
	var popup := button.get_popup()
	if object in context_menu_items:
		if property_name in context_menu_items[object]:
			var menu_items : Array[Dictionary] = context_menu_items[object][property_name]
			for item in menu_items:
				popup.add_item(item.name)
				popup.set_item_metadata(popup.item_count - 1, item.callable)
			popup.add_separator("Property Info", -1)
	for item in context_menu_property_info_items:
		popup.add_item(item.name)
		popup.set_item_metadata(popup.item_count - 1, item.callable)
	popup.index_pressed.connect(_on_popup_pressed.bindv([popup, ep]))

func _on_popup_pressed(index: int, popup: PopupMenu, ep: EditorProperty) -> void:
	popup.get_item_metadata(index).call(ep)

func _print_property_info(ep: EditorProperty) -> void:
	var property := H.PropertyInfo.get_property(ep.get_edited_object(), ep.get_edited_property())
	var obj := ep.get_edited_object()
	var prop := ep.get_edited_property()
	var name : String = '"%s"' % obj.name if ("name" in obj and obj.name) else\
		'"%s"' % obj.resource_name if ("resource_name" in obj and obj.resource_name) else\
		H.Scripts.get_class_name_or_script_name(obj)
	print("Property Info <", name, ".", prop, ">:\n", H.PropertyInfo.prettify(property))

func _print_editor_property_tree(ep: EditorProperty) -> void:
	ep.print_tree_pretty()

static func add_context_menu_item(
	object: Object,
	property_name: String, 
	item_name: String,
	callable: Callable,
) -> void:
	var property_items := _get_property_context_menu_items(object, property_name)
	property_items.push_back({ "name": item_name, "callable": callable })

static func _get_property_context_menu_items(object: Object, property_name: String) -> Array[Dictionary]:
	var object_data : Dictionary = context_menu_items.get_or_add(object, {})
	return object_data.get_or_add(property_name, [] as Array[Dictionary])