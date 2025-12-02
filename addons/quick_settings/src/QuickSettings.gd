extends PanelContainer

const NAME := "Quick Settings"
var hbox := HBoxContainer.new()

func _init() -> void:
	size_flags_vertical = SIZE_SHRINK_CENTER
	name = NAME
	theme = Theme.new()
	theme.set_constant(&"icon_max_width", &"Control", _get_desired_icon_size().x)
	add_child(hbox)

func _ready() -> void:
	add_theme_stylebox_override(
		"panel",
		EditorInterface.get_inspector().get_theme_stylebox(
			"PanelForeground",
			&"EditorStyles"
		)
	)
	for child in _get_descendents():
		if child is Button:
			_style_button(child)
		if child is PanelContainer:
			_style_panel(child)

func _style_button(button: Button) -> void:
	for state in [&"normal", &"pressed", &"hover", &"hover_pressed"]:
		button.add_theme_stylebox_override(state, EditorInterface.get_editor_theme().get_stylebox(state, "MainMenuBar"))
	button.focus_mode = Control.FOCUS_NONE
	button.icon = _size_icon(button.icon)

func _style_panel(panel: PanelContainer) -> void:
	panel.add_theme_stylebox_override(
		&"panel",
		EditorInterface.get_inspector().get_theme_stylebox(
			"Background",
			&"EditorStyles"
		)
	)

func _get_desired_icon_size() -> Vector2i:
	return Vector2.ONE * 16 * EditorInterface.get_editor_scale()

func _size_icon(tex: Texture2D) -> Texture2D:
	# ???
	if !tex:
		return null
	var tex_size := tex.get_size()
	var desired_size : Vector2i = Vector2.ONE * 16 * EditorInterface.get_editor_scale()
	if tex_size.is_equal_approx(desired_size):
		return tex
	var img : Image = tex.get_image()
	if tex is CompressedTexture2D:
		img.decompress()
	img.resize(desired_size.x, desired_size.y)
	return ImageTexture.create_from_image(img)


func add(c : Control) -> void:
	hbox.add_child(c)

func _get_descendents() -> Array[Node]:
	var arr : Array[Node]
	var parent_stack : Array[Node] = [self]
	while parent_stack.size():
		var parent = parent_stack.pop_front()
		for child in parent.get_children():
			parent_stack.push_back(child)
			arr.push_back(child)
	return arr
