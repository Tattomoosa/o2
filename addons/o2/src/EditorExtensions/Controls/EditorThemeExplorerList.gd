@tool
extends Container

@export var item_size : float = 32.0
@export var load_count := 100
var theme_type : String = "Panel"

func _ready() -> void:
	_populate()

func set_theme_type(type: String) -> void:
	theme_type = type
	_populate()

func _populate() -> void:
	pass
