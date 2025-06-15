@tool
extends PopupMenu

@export var tab_container : TabContainer

func _ready() -> void:
	await get_tree().process_frame
	tab_container.set_popup(self)