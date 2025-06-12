@tool
extends Button

@export_enum("Placeholder") var icon_name : String:
	set(value):
		icon_name = value
		_update_icon()

func _init(p_icon_name := "") -> void:
	var c := EditorInterface.get_base_control()
	if p_icon_name:
		_update_icon()
	for status in ["normal", "disabled", "hover", "pressed"]:
		add_theme_stylebox_override(
				status,
				c.get_theme_stylebox(status, &"InspectorActionButton")
			)

func _update_icon() -> void:
	var c := EditorInterface.get_base_control()
	add_theme_icon_override("icon", c.get_theme_icon(icon_name, &"EditorIcons"))

# func _validate_property(property: Dictionary) -> void:
# 	if property.name == "icon_name":
# 		property.hint = PROPERTY_HINT_ENUM_SUGGESTION
