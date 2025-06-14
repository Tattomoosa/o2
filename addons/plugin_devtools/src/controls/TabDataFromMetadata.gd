@tool
extends TabContainer

func _ready() -> void:
	var tab_bar := get_tab_bar()
	for i in get_child_count():
		if get_child(i).has_meta("icon"):
			var icon : Texture2D = get_child(i).get_meta("icon")
			icon = H.Editor.Plugins.ensure_icon_16x16_at_editor_scale(icon)
			tab_bar.set_tab_icon(i, icon)
