@tool
extends Container

@export var item_size := 100.0

var l := O2.logger.add_substream(O2.logger.LogLevel.DEBUG, "drag_palette")

func _ready() -> void:
	pass

func add_item(drop_data: Variant) -> void:
	l.debug("Dropped data: ", drop_data)
	if drop_data is Dictionary:
		l.info("Dropped data is dictionary")

		var panel := Panel.new()
		panel.custom_minimum_size = Vector2.ONE * item_size * H.Editor.Settings.scale

		var vbox := VBoxContainer.new()
		vbox.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
		panel.add_child(vbox)

		var label := Label.new()
		label.clip_text = true
		label.add_theme_font_size_override("font_size", 10 * H.Editor.Settings.scale)
		vbox.add_child(label)

		var previewer := TextureRect.new()
		previewer.size_flags_vertical = Control.SIZE_EXPAND_FILL
		previewer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		previewer.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		vbox.add_child(previewer)
		if drop_data.type == "resource":
			var resource : Resource = drop_data["resource"]
			label.text = resource.resource_name if resource.resource_name else H.Scripts.get_class_name_or_script_name(resource)
			_create_resource_preview(resource, previewer)
		if drop_data.type == "nodes":
			previewer.texture = EditorInterface.get_base_control().get_theme_icon("Node", &"EditorIcons")
			var nodes : Array = drop_data["nodes"]
			label.text = nodes[0].get_name(nodes[0].get_name_count() - 1)
			nodes.pop_front()
			if !nodes.is_empty():
				label.text += " + %s" % nodes.size()
		add_child(panel)
	else:
		l.warn("Dunno what to do lol")

func _create_resource_preview(resource: Resource, resource_previewer: TextureRect) -> void:
	var preview := EditorInterface.get_resource_previewer()
	preview.queue_edited_resource_preview(resource, self, "_on_resource_preview", resource_previewer)

func _on_resource_preview(path: String, preview: Texture2D, thumbnail: Texture2D, user_data_previewer: TextureRect) -> void:
	print("setting resource preview")
	user_data_previewer.texture = preview 

