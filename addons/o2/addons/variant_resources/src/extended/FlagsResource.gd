@tool
class_name FlagsResource
extends IntResource

enum FlagType {
	PHYSICS_2D,
	NAVIGATION_2D,
	RENDER_2D,
	PHYSICS_3D,
	NAVIGATION_3D,
	RENDER_3D,
	CUSTOM
}

const DEFAULT_CUSTOM_FLAGS := "1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32"

@export var flag_type : FlagType
@export var flag_names : PackedStringArrayResource

func _validate_property(property: Dictionary) -> void:
	if property.name == "value":
		match flag_type:
			FlagType.PHYSICS_2D:
				property.hint = PROPERTY_HINT_LAYERS_2D_PHYSICS
			FlagType.NAVIGATION_2D:
				property.hint = PROPERTY_HINT_LAYERS_2D_NAVIGATION
			FlagType.RENDER_2D:
				property.hint = PROPERTY_HINT_LAYERS_2D_RENDER
			FlagType.PHYSICS_3D:
				property.hint = PROPERTY_HINT_LAYERS_3D_PHYSICS
			FlagType.NAVIGATION_3D:
				property.hint = PROPERTY_HINT_LAYERS_3D_NAVIGATION
			FlagType.RENDER_3D:
				property.hint = PROPERTY_HINT_LAYERS_3D_RENDER
			FlagType.CUSTOM:
				property.hint = PROPERTY_HINT_FLAGS
				property.hint_string = DEFAULT_CUSTOM_FLAGS if !flag_names else ",".join(flag_names.value)
	elif property.name == "flag_type":
		property.usage |= PROPERTY_USAGE_UPDATE_ALL_IF_MODIFIED
	elif property.name == "flag_names":
		if flag_type != FlagType.CUSTOM:
			property.usage = PROPERTY_USAGE_STORAGE
	else:
		super(property)