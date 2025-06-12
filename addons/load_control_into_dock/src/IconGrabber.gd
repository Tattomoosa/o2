# Stolen shamelessly from
# https://github.com/PiCode9560/Godot-Inspector-Tabs/blob/main/addons/inspector_tabs/icon_grabber.gd
# and modified to be self-contained and refcounted

extends RefCounted

var UNKNOWN_ICON:Texture2D = EditorInterface.get_base_control().get_theme_icon("", "EditorIcons")

var script_editor

var editor_help_search:Window
var tree:Tree
var search_bar:LineEdit
var open_help_button:Button
var filter_option_button:OptionButton

var project_settings_editor # Project settings window

var icon_list = {}

var finish = false

# Get icon
func get_icon(_class:String) -> ImageTexture:
	if icon_list.has(_class):
		return icon_list[_class]
	else:
		return null
	
# Store icons
func update_icon_list():
	script_editor = EditorInterface.get_script_editor()
	editor_help_search = NodeFinder.find_by_class(script_editor,"EditorHelpSearch",2)
	project_settings_editor = NodeFinder.find_by_class(EditorInterface.get_base_control(),"ProjectSettingsEditor",3)
	tree = NodeFinder.find_by_class(editor_help_search,"Tree",5)
	search_bar = NodeFinder.find_by_class(editor_help_search,"LineEdit",5)
	filter_option_button = NodeFinder.find_by_class(editor_help_search,"OptionButton",5)
	open_help_button = script_editor.get_child(0).get_child(0).get_children().filter(func(node): return node.get_class() == "Button")[1]
	
	finish = false
	# Wait until project settings is closed to prevent error
	while project_settings_editor.visible == true:
		await script_editor.get_tree().process_frame

	icon_list.clear()
	
	search_bar.text = ""
	var current_filter = filter_option_button.selected
	filter_option_button.selected = 2
	
	# Open the editor help search
	open_help_button.pressed.emit()
	
	# wait until tree loaded.
	while tree.get_root() == null:
		await script_editor.get_tree().process_frame
	
	# wait until tree items is fully loaded.
	while is_tree_fully_loaded(tree) != true:
		await script_editor.get_tree().process_frame
	
	# Get the GDExtension icons
	grab_icon(tree.get_root())
	
	# Wait until the icons is finished grabbing
	while finish != true:
		await script_editor.get_tree().process_frame
	
	# Reset editor help search
	editor_help_search.hide()
	filter_option_button.selected = current_filter
	
func is_tree_fully_loaded(tree:Tree) -> bool:
	for item in tree.get_root().get_children():
		for i in tree.columns:
			if item.get_text(i) == "Vector4i":
				return true
	
	return false
	
func grab_icon(from_item:TreeItem):
	for item:TreeItem in from_item.get_children():
		#if item.get_text(1) == "Class":
			var c_name = item.get_text(0)
			
			# If it at the end of the tree
			if c_name == "Vector4i":
				finish = true
			
			# Get GDExtension icons only
			if ClassDB.class_exists(c_name) and ClassDB.class_get_api_type(c_name) == ClassDB.APIType.API_EXTENSION:
				var icon = item.get_icon(0)
				
				if icon is CompressedTexture2D:
					icon = ImageTexture.create_from_image(icon.get_image())
				icon_list[c_name] = icon
			
			# Go deeper into the tree
			grab_icon(item)

func get_class_icon(c_name:String) -> Texture2D:
	var base_control = EditorInterface.get_base_control()
	
	#Get GDExtension Icon
	var load_icon = get_icon(c_name)
	if load_icon != null:
		return load_icon
	load_icon = UNKNOWN_ICON
	
	
	if c_name.ends_with(".gd"):# GDScript Icon
		load_icon = base_control.get_theme_icon("GDScript", "EditorIcons")
	if c_name == "RefCounted":# RefCounted Icon
		load_icon = base_control.get_theme_icon("Object", "EditorIcons")
	elif ClassDB.class_exists(c_name): # Get editor icon
		load_icon = base_control.get_theme_icon(c_name, "EditorIcons")
	else:
		# Get custom class icon
		for list in ProjectSettings.get_global_class_list():
			if list.class == c_name:
				if list.icon != "":
					var texture:Texture2D = load(list.icon)
					return texture
					# var image = texture.get_image()
					# image.resize(load_icon.get_width(),load_icon.get_height())
					# return ImageTexture.create_from_image(image)
				break

	if load_icon != UNKNOWN_ICON:
		return load_icon # Return if icon is not unknown
	
	# if icon not found just use the node disabled icon
	return base_control.get_theme_icon("NodeDisabled", "EditorIcons")

# Find node from a node
class NodeFinder:
	var out_node:Node

	static func find_by_class(from_node:Node,_class:String, depth:int = 10000) -> Node:
		var finder = NodeFinder.new()
		finder._find_by_class(from_node, _class, depth)
		return finder.out_node
		
	func _find_by_class(from_node:Node, _class:String, depth:int = 10000) -> void:
		if out_node != null or depth <= 0:return
		for child in from_node.get_children():
			if child.get_class() == _class:
				out_node = child
				return
			_find_by_class(child, _class, depth - 1)
