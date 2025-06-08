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
	AVOIDANCE,
	CUSTOM
}

@export_group("Flag settings", "flag_")
@export var flag_type : FlagType:
	set(v):
		flag_type = v
		notify_property_list_changed()
@export var flag_names : PackedStringArrayResource:
	set(v):
		flag_names = v
		notify_property_list_changed()
@export var flag_count : int = 4

func _validate_property(property: Dictionary) -> void:
	if property.name == "value" and !_override_property_hint:
		property.usage |= PROPERTY_USAGE_CLASS_IS_BITFIELD
		match flag_type:
			FlagType.RENDER_2D:
				property.hint = PROPERTY_HINT_LAYERS_2D_RENDER
			FlagType.PHYSICS_2D:
				property.hint = PROPERTY_HINT_LAYERS_2D_PHYSICS
			FlagType.NAVIGATION_2D:
				property.hint = PROPERTY_HINT_LAYERS_2D_NAVIGATION
			FlagType.RENDER_3D:
				property.hint = PROPERTY_HINT_LAYERS_3D_RENDER
			FlagType.PHYSICS_3D:
				property.hint = PROPERTY_HINT_LAYERS_3D_PHYSICS
			FlagType.NAVIGATION_3D:
				property.hint = PROPERTY_HINT_LAYERS_3D_NAVIGATION
			FlagType.AVOIDANCE:
				property.hint = PROPERTY_HINT_LAYERS_AVOIDANCE
			FlagType.CUSTOM:
				property.hint = PROPERTY_HINT_FLAGS
				property.hint_string = _get_default_custom_flags() if !flag_names else ",".join(flag_names.value)
	elif property.name == "flag_type":
		property.usage |= PROPERTY_USAGE_UPDATE_ALL_IF_MODIFIED
	elif property.name == "flag_names":
		if flag_type != FlagType.CUSTOM:
			property.usage = PROPERTY_USAGE_STORAGE
	elif property.name == "flag_count":
		if flag_type != FlagType.CUSTOM or flag_names:
			property.usage = PROPERTY_USAGE_STORAGE
		else:
			property.usage |= PROPERTY_USAGE_UPDATE_ALL_IF_MODIFIED
	else:
		super(property)

func _get_default_custom_flags() -> String:
	var counter := PackedStringArray([])
	counter.resize(flag_count)
	for i in flag_count:
		counter[i] = str(i + 1)
	return ",".join(counter)