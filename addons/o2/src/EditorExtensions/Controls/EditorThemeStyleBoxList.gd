@tool
extends Container

signal mouse_hovered_button(icon_name: String)
signal button_pressed

@export var item_size : float = 32.0
@export var load_count := 100
var theme_type : String = "Panel"

func _ready() -> void:
	_populate()

func set_theme_type(type: String) -> void:
	theme_type = type
	_populate()

func _populate() -> void:
	for child in get_children():
		child.queue_free()
	var t := EditorInterface.get_editor_theme()
	var stylebox_names := t.get_stylebox_list(theme_type)
	var loaded := 0
	for item_name in stylebox_names:
		var btn := Button.new()
		var style := t.get_stylebox(item_name, theme_type)
		if true: # styles
			for state in ["normal", "pressed", "hover"]:
				btn.add_theme_stylebox_override(state, style)
			if false: # hover style
				var hover_style := StyleBoxFlat.new()
				hover_style.border_color = Color.WHITE
				hover_style.set_border_width_all(5)
				if "bg_color" in style:
					hover_style.bg_color = style.bg_color
				else:
					hover_style.bg_color = Color.TRANSPARENT
				btn.add_theme_stylebox_override("hover", hover_style)
		btn.name = item_name
		btn.custom_minimum_size.y = item_size
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.text = item_name
		btn.mouse_entered.connect(mouse_hovered_button.emit.bind(item_name))
		btn.mouse_exited.connect(mouse_hovered_button.emit.bind(""))
		btn.pressed.connect(DisplayServer.clipboard_set.bind(item_name))
		btn.pressed.connect(button_pressed.emit)
		btn.set_drag_forwarding(
			_get_item_drag_data.bindv([btn, style]),
			Callable(),
			Callable()
		)
		add_child(btn)
		loaded += 1
		if loaded >= load_count:
			await get_tree().process_frame
			loaded = 0

func _get_item_drag_data(_pos: Vector2, button: Button, style: StyleBox) -> Variant:
	var d_offset := Control.new()
	var d_preview := button.duplicate()
	d_preview.size.x = item_size * H.Editor.Settings.scale
	d_offset.add_child(d_preview)
	d_preview.position -= Vector2(50,50)
	set_drag_preview(d_offset)
	return {
		"type": "resource",
		"resource": style
	}
	
func filter(text: String) -> void:
	if text:
		for child in get_children():
			child.visible = text.to_lower() in child.name.to_lower()
	else:
		for child in get_children():
			child.show()