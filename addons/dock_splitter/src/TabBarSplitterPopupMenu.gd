@tool
extends MenuButton

const Splitter := preload("Splitter.gd")

@export var splitter : Splitter

var _popup : PopupMenu

func _ready() -> void:
	_popup = get_popup()
	_popup.index_pressed.connect(_index_pressed)
	splitter.can_close.connect(enable_close)

func enable_close(value: bool) -> void:
	_popup.set_item_disabled(2, !value)

func _index_pressed(idx: int) -> void:
	match idx:
		0: splitter.split_horizontal()
		1: splitter.split_vertical()
		2: splitter.close()