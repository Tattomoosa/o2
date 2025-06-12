@tool
extends Container

signal mouse_hovered_button(icon_name: String)
signal button_pressed

@export_tool_button("Reload") var reload_button := _populate
@export var icon_size : float = 32.0
@export var load_count := 100
var theme_type : String = "EditorIcons"

func _ready() -> void:
	_populate()

func set_theme_type(type: String) -> void:
	theme_type = type
	_populate()

func _populate() -> void:
	for child in get_children():
		child.queue_free()
	var t := EditorInterface.get_editor_theme()
	var icon_names := t.get_icon_list(theme_type)
	var loaded := 0
	for icon_name in icon_names:
		var icon_button := Button.new()
		icon_button.expand_icon = true
		icon_button.icon = _load_icon(icon_name)
		icon_button.custom_minimum_size = Vector2.ONE * icon_size * H.Editor.Settings.scale
		icon_button.tooltip_text = icon_name
		icon_button.name = icon_name
		icon_button.mouse_entered.connect(mouse_hovered_button.emit.bind(icon_name))
		icon_button.mouse_exited.connect(mouse_hovered_button.emit.bind(""))
		icon_button.pressed.connect(DisplayServer.clipboard_set.bind(icon_name))
		icon_button.pressed.connect(button_pressed.emit)
		icon_button.set_drag_forwarding(
			_get_item_drag_data.bind(icon_button),
			Callable(),
			Callable()
		)
		add_child(icon_button)
		loaded += 1
		if loaded >= load_count:
			await get_tree().process_frame
			loaded = 0

func _get_names() -> Array[String]:
	var t := EditorInterface.get_editor_theme()
	return t.get_icon_list(theme_type)

func _load_icon(icon_name: String) -> Texture2D:
	var t := EditorInterface.get_editor_theme()
	return t.get_icon(icon_name, theme_type)

func _get_item_drag_data(_pos: Vector2, button: Button) -> Variant:
	var d_offset := Control.new()
	var d_preview := TextureRect.new()
	d_preview.texture = button.icon
	d_preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	d_preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	d_preview.position -= Vector2(50,50)
	d_preview.size = button.size
	d_offset.add_child(d_preview)
	set_drag_preview(d_offset)
	return {
		"type": "resource",
		"resource": button.icon
	}

func set_item_size(v: float) -> void:
	icon_size = v
	for item in get_children():
		item.custom_minimum_size = Vector2.ONE * v * H.Editor.Settings.scale
	
func filter(text: String) -> void:
	if text:
		for child in get_children():
			child.visible = text.to_lower() in child.name.to_lower()
	else:
		for child in get_children():
			child.show()
