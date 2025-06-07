@tool
@icon("../../assets/icons/Dictionary.svg")
class_name DictionaryResource
extends VariantResource

@export var value : Dictionary:
	get: return _value
	set(v): _set_value(v)

func _init() -> void:
	_type = TYPE_DICTIONARY
	_value = {}
