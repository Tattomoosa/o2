extends MenuButton

const WINDOW_MODE_PROJECT_SETTING := "display/window/size/mode"

const SETTING_HIDE_WINDOWED := "hide_windowed"
const SETTING_HIDE_MINIMIZED := "hide_minimized"
const SETTING_HIDE_MAXIMIZED := "hide_maximized"
const SETTING_HIDE_FULLSCREEN := "hide_fullscreen"
const SETTING_HIDE_EXCLUSIVE := "hide_exclusive_fullscreen"


const WINDOW_MODE_NAMES := [
	"Windowed",
	"Minimized",
	"Maximized",
	"Fullscreen",
	"Exclusive Fullscreen"
]
const WINDOW_MODE_ICONS := [
	preload("uid://fn0eei6p3yjp"),
	preload("uid://gx6n7a22ff08"),
	preload("uid://c0n8je0ay0xrr"),
	preload("uid://dgu6tcm1gipit"),
	preload("uid://dowhguqwdugdx")
]


# Will be added to SETTINGS and updated by quick_settings
var settings := {
	SETTING_HIDE_WINDOWED: false,
	SETTING_HIDE_MINIMIZED: true,
	SETTING_HIDE_MAXIMIZED: false,
	SETTING_HIDE_FULLSCREEN: false,
	SETTING_HIDE_EXCLUSIVE: false,
}

func _ready() -> void:
	name = "WindowModeMenu"
	tooltip_text = "Change the gameplay window mode"
	_create_popup()

func _create_popup() -> void:
	var popup := get_popup()
	popup.min_size = Vector2.ZERO
	popup.clear()
	if !settings[SETTING_HIDE_WINDOWED]:
		popup.add_icon_radio_check_item(WINDOW_MODE_ICONS[0], WINDOW_MODE_NAMES[0], DisplayServer.WindowMode.WINDOW_MODE_WINDOWED)
	if !settings[SETTING_HIDE_MINIMIZED]:
		popup.add_icon_radio_check_item(WINDOW_MODE_ICONS[1], WINDOW_MODE_NAMES[1], DisplayServer.WindowMode.WINDOW_MODE_MINIMIZED)
	if !settings[SETTING_HIDE_MAXIMIZED]:
		popup.add_icon_radio_check_item(WINDOW_MODE_ICONS[2], WINDOW_MODE_NAMES[2], DisplayServer.WindowMode.WINDOW_MODE_MAXIMIZED)
	if !settings[SETTING_HIDE_FULLSCREEN]:
		popup.add_icon_radio_check_item(WINDOW_MODE_ICONS[3], WINDOW_MODE_NAMES[3], DisplayServer.WindowMode.WINDOW_MODE_FULLSCREEN)
	if !settings[SETTING_HIDE_EXCLUSIVE]:
		popup.add_icon_radio_check_item(WINDOW_MODE_ICONS[4], WINDOW_MODE_NAMES[4], DisplayServer.WindowMode.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	var value : int = ProjectSettings.get_setting(WINDOW_MODE_PROJECT_SETTING)
	for i in popup.item_count:
		if popup.get_item_id(i) == value:
			popup.set_item_checked(i, true)
	_update()

	if !popup.about_to_popup.is_connected(_create_popup):
		popup.about_to_popup.connect(_create_popup)
	if !popup.id_pressed.is_connected(_id_pressed):
		popup.id_pressed.connect(_id_pressed)
	if !ProjectSettings.settings_changed.is_connected(_update):
		ProjectSettings.settings_changed.connect(_update)

func _id_pressed(index: int) -> void:
	ProjectSettings.set_setting(WINDOW_MODE_PROJECT_SETTING, index)
	ProjectSettings.save()

func _update() -> void:
	var window_mode : int = ProjectSettings.get_setting("display/window/size/mode")
	name = WINDOW_MODE_NAMES[window_mode]
	icon = WINDOW_MODE_ICONS[window_mode]