@tool
extends Container

signal mouse_hovered(color_name: String)
signal button_pressed

const ColorMapButton := preload("ColorMapButton.gd")
const ColorMap := H.Editor.ColorMap

@export var color_map_button_scene : PackedScene

func _ready() -> void:
	var t := EditorInterface.get_editor_theme()
	for og_color in ColorMap.get_base_colors():
		var btn : ColorMapButton = color_map_button_scene.instantiate()
		btn.og_color = og_color
		btn.mapped_color = ColorMap.get_mapped_color(og_color)
		btn.text = "#%s (%s)" % [og_color.to_html(), ColorMap.get_color_name(og_color)]
		btn.add_theme_font_override("font", t.get_font("bold", "EditorFonts"))
		btn.add_theme_constant_override(
			"outline_size", 
			int(4 * EditorInterface.get_editor_scale())
		)
		btn.mouse_entered.connect(mouse_hovered.emit.bind(og_color.to_html(false)))
		btn.mouse_exited.connect(mouse_hovered.emit.bind(""))
		btn.pressed.connect(button_pressed.emit)
		btn.pressed.connect(DisplayServer.clipboard_set.bind(og_color.to_html(false)))
		add_child(btn)
	await get_tree().process_frame
	var max_x := 0
	for child : ColorMapButton in get_children():
		max_x = max(max_x, child.size.x)
	for child : ColorMapButton in get_children():
		child.custom_minimum_size.x = max_x