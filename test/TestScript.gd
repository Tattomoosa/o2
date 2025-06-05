class_name TestScript
extends Node

func _ready() -> void:
	var c_name := O2.Helpers.Scripts.get_class_name(self)
	print(c_name)
	pass
