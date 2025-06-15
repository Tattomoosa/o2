@tool
@icon("../../assets/icons/Basis.svg")
class_name BasisResource
extends VariantResource

## Basis value
@export var value : Basis:
	get: return _value
	set(v): _set_value(v)

func _init() -> void:
	_type = TYPE_BASIS
	_value = Basis()

func get_type() -> Variant.Type:
	return TYPE_BASIS