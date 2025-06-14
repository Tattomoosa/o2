@tool
extends Tree

signal property_selected(property_name: String)

var selected_property : String = ""

func _ready() -> void:
	EditorInterface.get_inspector().edited_object_changed.connect(_build_tree)
	EditorInterface.get_inspector().property_selected.connect(_find_property)
	item_mouse_selected.connect(_on_item_selected.unbind(2))

# TODO pretty sure this will break for bad input pretty bad lol
func _build_tree() -> void:
	clear()
	var object := EditorInterface.get_inspector().get_edited_object()
	if !object:
		return
	var root := create_item()
	var parent = root
	var group_parent = null
	var subgroup_parent = null
	for p in object.get_property_list():
		var item : TreeItem
		if p.usage == PROPERTY_USAGE_CATEGORY:
			item = create_item(root)
			item.set_custom_font_size(0, 45)
			item.set_custom_bg_color(0, Color(Color.WHITE, 0.05))
			parent = item
			group_parent = null
			subgroup_parent = null
		elif p.usage == PROPERTY_USAGE_GROUP:
			if subgroup_parent:
				parent = parent.get_parent()
			if group_parent:
				parent = parent.get_parent()
			item = create_item(parent)
			item.set_custom_font_size(0, 35)
			item.set_custom_bg_color(0, Color(Color.WHITE, 0.02))
			group_parent = parent
			subgroup_parent = null
			parent = item
		elif p.usage == PROPERTY_USAGE_SUBGROUP:
			if subgroup_parent:
				parent = parent.get_parent()
			item = create_item(parent)
			item.set_custom_bg_color(0, Color(Color.WHITE, 0.01))
			item.set_custom_font_size(0, 30)
			subgroup_parent = parent
			parent = item
		else:
			item = create_item(parent)
		item.set_text(0, p.name)

func _find_property(property: String, root = null) -> void:
	if !root:
		root = get_root()
		for child in root.get_children():
			child.set_collapsed_recursive(true)
	for item : TreeItem in root.get_children():
		if item.get_text(0) == property:
			scroll_to_item(item)
			var parent := item
			while parent:
				parent.collapsed = false
				parent = parent.get_parent()
			item.select(0)
			return
		_find_property(property, item)

func _on_item_selected() -> void:
	var item := get_selected()
	if !item:
		return
	item.collapsed = !item.collapsed
	var p_name := item.get_text(0)
	if p_name != selected_property:
		property_selected.emit(p_name)
		selected_property = p_name
