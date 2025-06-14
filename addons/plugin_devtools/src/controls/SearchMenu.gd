@tool
# class_name SearchMenu
extends LineEdit

@export var options : PackedStringArray = []
# TODO theme and stuff
@export var popup_panel_style : StyleBox
@export var clear_on_focus := true

@onready var popup : PopupPanel = %PopupPanel
@onready var options_container : VBoxContainer = %OptionList
@onready var popup_line_edit : LineEdit = %PopupLineEdit

func _ready() -> void:
	if text.is_empty() or text not in options:
		text = options[0] if !options.is_empty() else ""
	popup.hide()
	focus_entered.connect(_focused)
	text_changed.connect(_focused.unbind(1))
	popup_line_edit.text_submitted.connect(_line_edit_submitted)
	popup_line_edit.text_changed.connect(_set_options_visible)
	popup.popup_hide.connect(_popup_hidden)
	_populate_options()

func _popup_hidden() -> void:
	unedit()
	release_focus()

func _line_edit_submitted(_new_text: String) -> void:
	var selected_option = _get_first_visible_child_text()
	if selected_option:
		text = selected_option
	caret_column = popup_line_edit.caret_column
	popup.hide()
	unedit()
	release_focus()

func _populate_options() -> void:
	# TODO this dumb but ehhh
	for child in options_container.get_children():
		child.queue_free()
	for option in options:
		var label := Label.new()
		options_container.add_child(label)
		label.text = option

func _focused() -> void:
	_populate_options()
	popup.position = get_screen_position()
	popup.size.x = int(size.x)
	_set_options_visible("")
	popup.popup.call_deferred()
	popup_line_edit.caret_column = caret_column
	popup_line_edit.text = "" if clear_on_focus else text
	popup_line_edit.grab_focus.call_deferred()

func _set_options_visible(entered_text: String) -> void:
	for child : Label in options_container.get_children():
		child.visible = !entered_text or entered_text.to_lower() in child.text.to_lower()

func _get_first_visible_child_text() -> String:
	for child : Label in options_container.get_children():
		if child.visible:
			return child.text
	return ""
