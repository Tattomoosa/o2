@tool
extends EditorPlugin

var titlebar : Control
var main_screen_buttons : HBoxContainer

func _enable_plugin() -> void:
	# Add autoloads here.
	pass

func _disable_plugin() -> void:
	# Remove autoloads here.
	pass

func _enter_tree() -> void:
	_get_interface_elements()
	add_child(HideMainScreenButtonNames.new(main_screen_buttons))
	add_child(HideRendererMenuButton.new(titlebar))

func _exit_tree() -> void:
	for child in get_children():
		child.queue_free()

func _get_interface_elements() -> void:
	var c := Control.new()
	add_control_to_container(CustomControlContainer.CONTAINER_TOOLBAR, c)
	titlebar = c.get_parent()
	c.queue_free()
	main_screen_buttons = titlebar.get_node("EditorMainScreenButtons")

class HideRendererMenuButton extends Node:
	var titlebar : HBoxContainer
	var _renderer_button : Button

	func _init(p_titlebar : Control) -> void:
		titlebar = p_titlebar

	func _enter_tree() -> void:
		for i in range(titlebar.get_child_count() -1, -1, -1):
			var c := titlebar.get_child(i)
			if c is HBoxContainer:
				for child in c.get_children():
					if child is not Button:
						continue
					if child.text in ["Forward+", "Mobile", "Compatibility"]:
						_renderer_button = child
						_renderer_button.hide()

	func _exit_tree() -> void:
		_renderer_button.show()

# Can't hide main screen buttons or the corresponding main screen doesn't work...
# But you can hide their names!
class HideMainScreenButtonNames extends Node:
	var main_screen_buttons : HBoxContainer

	func _init(p_main_screen_buttons : HBoxContainer) -> void:
		main_screen_buttons = p_main_screen_buttons

	func _enter_tree() -> void:
		for c in main_screen_buttons.get_children():
			c.text = ""
	
	# ehh ugly still
	# func hide_button(btn_name: String) -> void:
	# 	var btn : Button = main_screen_buttons.get_node(btn_name)
	# 	btn.name = ""
	# 	btn.expand_icon = true
	
	func _exit_tree() -> void:
		for c in main_screen_buttons.get_children():
			c.text = c.name
			c.expand_icon = false
