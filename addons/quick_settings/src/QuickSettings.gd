extends HBoxContainer

func _init() -> void:
	size_flags_vertical = SIZE_SHRINK_CENTER
	name = "Quick Settings"
	add_child(VSeparator.new(), false, INTERNAL_MODE_FRONT)
	add_child(VSeparator.new(), false, INTERNAL_MODE_BACK)

func _ready() -> void:
	for child in get_children():
		if child is Button:
			_style_button(child)

func _style_button(button: Button) -> void:
	for state in ["normal", "pressed", "hover", "hover_pressed"]:
		button.add_theme_stylebox_override(state, EditorInterface.get_editor_theme().get_stylebox(state, "MainMenuBar"))
	button.focus_mode = Control.FOCUS_NONE