@tool
@icon("../../assets/icons/Array.svg")
class_name ArrayResource
extends VariantResource

const _PropertyInfo := O2.Helpers.PropertyInfo

# not sure this one is useful lol
enum TestEnum {
	ONE,
	TWO
}

@export var value : Array:
	get: return _value
	set(v): _set_value(v)

@export_group("Type Restrictions", "type_restrict")
@export var type_restrict_enabled := false
@export var type_restrict_to_type : Variant.Type = TYPE_NIL
@export var type_restrict_to_resource : StringName = &""
@export var type_restrict_hint_string : String

func _init() -> void:
	_type = TYPE_ARRAY
	_value = []

func _validate_property(property: Dictionary) -> void:
	super(property)

	if property.name == "type_restrict_enabled":
		property.usage |= PROPERTY_USAGE_UPDATE_ALL_IF_MODIFIED

	if property.name == "type_restrict_to_type":
		property.usage |= PROPERTY_USAGE_UPDATE_ALL_IF_MODIFIED
	
	if property.name == "type_restrict_hint_string":
		property.usage |= PROPERTY_USAGE_READ_ONLY

	if property.name == "value" and !_override_property_hint:
		if type_restrict_enabled:
			if type_restrict_to_type != TYPE_OBJECT:
				property.hint = PROPERTY_HINT_ARRAY_TYPE
				property.hint_string = type_string(type_restrict_to_type)
			else:
				property.hint = PROPERTY_HINT_TYPE_STRING
				property.hint_string = _PropertyInfo.construct_array_hint_type_string(
					[type_restrict_to_type],
					(
						[0] if !type_restrict_to_resource else [PROPERTY_HINT_RESOURCE_TYPE]
					) as Array[int],
					type_restrict_to_resource
				)
			type_restrict_hint_string = property.hint_string