@tool
class_name TestScript
extends Node

@export var resource : VariantResource

func _init() -> void:
	pass
	# if Engine.is_editor_hint():
		# print(O2.Helpers.PropertyInfo.prettify(O2.Helpers.PropertyInfo.get_property(self, "file")))

func _ready() -> void:
	pass