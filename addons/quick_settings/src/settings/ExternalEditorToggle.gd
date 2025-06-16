extends Button

const INTERNAL_EDITOR_ICON := preload("uid://da5t0jkc41bal")
const EXTERNAL_EDITOR_ICON := preload("uid://q1hy0uael7v6")

var es := EditorInterface.get_editor_settings()

func _ready() -> void:
	tooltip_text = "Enable/disable external code editing"
	flat = true
	focus_mode = Control.FOCUS_NONE
	es.settings_changed.connect(_update)
	name = "ExternalEditorToggle"
	_update()

func _pressed() -> void:
	es.set("text_editor/external/use_external_editor", !es.get("text_editor/external/use_external_editor"))

func _update() -> void:
	var value : bool = es.get("text_editor/external/use_external_editor")
	# icon = EXTERNAL_EDITOR_ICON if value else INTERNAL_EDITOR_ICON
	add_theme_icon_override("icon", EXTERNAL_EDITOR_ICON if value else INTERNAL_EDITOR_ICON)
