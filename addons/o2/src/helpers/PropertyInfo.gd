const USAGE_FLAG_STRINGS : Dictionary[int, StringName] = {
	# special
	0: &"PROPERTY_USAGE_NONE",
	6: &"PROPERTY_USAGE_DEFAULT",
	# normal bitflags
	2: &"PROPERTY_USAGE_STORAGE",
	4: &"PROPERTY_USAGE_EDITOR",
	8: &"PROPERTY_USAGE_INTERNAL",
	16: &"PROPERTY_USAGE_CHECKABLE",
	32: &"PROPERTY_USAGE_CHECKED",
	64: &"PROPERTY_USAGE_GROUP",
	128: &"PROPERTY_USAGE_CATEGORY",
	256: &"PROPERTY_USAGE_SUBGROUP",
	512: &"PROPERTY_USAGE_CLASS_IS_BITFIELD",
	1024: &"PROPERTY_USAGE_NO_INSTANCE_STATE",
	2048: &"PROPERTY_USAGE_RESTART_IF_CHANGED",
	4096: &"PROPERTY_USAGE_SCRIPT_VARIABLE",
	8192: &"PROPERTY_USAGE_STORE_IF_NULL",
	16384: &"PROPERTY_USAGE_UPDATE_ALL_IF_MODIFIED",
	32768: &"PROPERTY_USAGE_SCRIPT_DEFAULT_VALUE",
	65536: &"PROPERTY_USAGE_CLASS_IS_ENUM",
	131072: &"PROPERTY_USAGE_NIL_IS_VARIANT",
	262144: &"PROPERTY_USAGE_ARRAY",
	524288: &"PROPERTY_USAGE_ALWAYS_DUPLICATE",
	1048576: &"PROPERTY_USAGE_NEVER_DUPLICATE",
	2097152: &"PROPERTY_USAGE_HIGH_END_GFX",
	4194304: &"PROPERTY_USAGE_NODE_PATH_FROM_SCENE_ROOT",
	8388608: &"PROPERTY_USAGE_RESOURCE_NOT_PERSISTENT",
	16777216: &"PROPERTY_USAGE_KEYING_INCREMENTS",
	33554432: &"PROPERTY_USAGE_DEFERRED_SET_RESOURCE",
	67108864: &"PROPERTY_USAGE_EDITOR_INSTANTIATE_OBJECT",
	134217728: &"PROPERTY_USAGE_EDITOR_BASIC_SETTING",
	268435456: &"PROPERTY_USAGE_READ_ONLY",
	536870912: &"PROPERTY_USAGE_SECRET",
}
const TYPE_STRINGS : Array[String] = [
	&"TYPE_NIL",
	&"TYPE_BOOL",
	&"TYPE_INT",
	&"TYPE_FLOAT",
	&"TYPE_STRING",
	&"TYPE_VECTOR2",
	&"TYPE_VECTOR2I",
	&"TYPE_RECT2",
	&"TYPE_RECT2I",
	&"TYPE_VECTOR3",
	&"TYPE_VECTOR3I",
	&"TYPE_TRANSFORM2D",
	&"TYPE_VECTOR4",
	&"TYPE_VECTOR4I",
	&"TYPE_PLANE",
	&"TYPE_QUATERNION",
	&"TYPE_AABB",
	&"TYPE_BASIS",
	&"TYPE_TRANSFORM3D",
	&"TYPE_PROJECTION",
	&"TYPE_COLOR",
	&"TYPE_STRING_NAME",
	&"TYPE_NODE_PATH",
	&"TYPE_RID",
	&"TYPE_OBJECT",
	&"TYPE_CALLABLE",
	&"TYPE_SIGNAL",
	&"TYPE_DICTIONARY",
	&"TYPE_ARRAY",
	&"TYPE_PACKED_BYTE_ARRAY",
	&"TYPE_PACKED_INT32_ARRAY",
	&"TYPE_PACKED_INT64_ARRAY",
	&"TYPE_PACKED_FLOAT32_ARRAY",
	&"TYPE_PACKED_FLOAT64_ARRAY",
	&"TYPE_PACKED_STRING_ARRAY",
	&"TYPE_PACKED_VECTOR2_ARRAY",
	&"TYPE_PACKED_VECTOR3_ARRAY",
	&"TYPE_PACKED_COLOR_ARRAY",
	&"TYPE_PACKED_VECTOR4_ARRAY",
	&"TYPE_MAX",
]

const PROPERTY_HINT_STRINGS : Array[StringName] = [
	&"PROPERTY_HINT_NONE",
	&"PROPERTY_HINT_RANGE",
	&"PROPERTY_HINT_ENUM",
	&"PROPERTY_HINT_ENUM_SUGGESTION",
	&"PROPERTY_HINT_EXP_EASING",
	&"PROPERTY_HINT_LINK",
	&"PROPERTY_HINT_FLAGS",
	&"PROPERTY_HINT_LAYERS_2D_RENDER",
	&"PROPERTY_HINT_LAYERS_2D_PHYSICS",
	&"PROPERTY_HINT_LAYERS_2D_NAVIGATION",
	&"PROPERTY_HINT_LAYERS_3D_RENDER",
	&"PROPERTY_HINT_LAYERS_3D_PHYSICS",
	&"PROPERTY_HINT_LAYERS_3D_NAVIGATION",
	&"PROPERTY_HINT_FILE",
	&"PROPERTY_HINT_DIR",
	&"PROPERTY_HINT_GLOBAL_FILE",
	&"PROPERTY_HINT_GLOBAL_DIR",
	&"PROPERTY_HINT_RESOURCE_TYPE",
	&"PROPERTY_HINT_MULTILINE_TEXT",
	&"PROPERTY_HINT_EXPRESSION",
	&"PROPERTY_HINT_PLACEHOLDER_TEXT",
	&"PROPERTY_HINT_COLOR_NO_ALPHA",
	&"PROPERTY_HINT_OBJECT_ID",
	&"PROPERTY_HINT_TYPE_STRING",
	&"PROPERTY_HINT_NODE_PATH_TO_EDITED_NODE",
	&"PROPERTY_HINT_OBJECT_TOO_BIG",
	&"PROPERTY_HINT_NODE_PATH_VALID_TYPES",
	&"PROPERTY_HINT_SAVE_FILE",
	&"PROPERTY_HINT_GLOBAL_SAVE_FILE",
	&"PROPERTY_HINT_INT_IS_OBJECTID",
	&"PROPERTY_HINT_INT_IS_POINTER",
	&"PROPERTY_HINT_ARRAY_TYPE",
	&"PROPERTY_HINT_DICTIONARY_TYPE",
	&"PROPERTY_HINT_LOCALE_ID",
	&"PROPERTY_HINT_LOCALIZABLE_STRING",
	&"PROPERTY_HINT_NODE_TYPE",
	&"PROPERTY_HINT_HIDE_QUATERNION_EDIT",
	&"PROPERTY_HINT_PASSWORD",
	&"PROPERTY_HINT_LAYERS_AVOIDANCE",
	&"UNUSED",
	&"PROPERTY_HINT_TOOL_BUTTON",
	&"PROPERTY_HINT_ONESHOT",
	&"UNUSED",
	&"PROPERTY_HINT_MAX",
]

static func get_usage_flag_names(usage: int) -> Array[StringName]:
	var used_flag_strings : Array[StringName] = []
	if usage in USAGE_FLAG_STRINGS.keys():
		used_flag_strings.append(USAGE_FLAG_STRINGS[usage])
	else:
		for flag in USAGE_FLAG_STRINGS.keys():
			if has_flag(usage, flag):
				used_flag_strings.append(USAGE_FLAG_STRINGS[flag])
	return used_flag_strings

static func has_flag(bits: int, flag: int) -> bool:
	return bits & flag != 0

static func set_flag(bits: int, flag: int) -> int:
	return bits | flag

static func unset_flag(bits: int, flag: int) -> int:
	return bits & ~flag

static func get_type_name(type: int) -> StringName:
	return TYPE_STRINGS[type]

static func get_property_hint_name(property_hint: int) -> StringName:
	return PROPERTY_HINT_STRINGS[property_hint]

static func prettify(property: Dictionary) -> String:
	var prop_str := "[ %s ]\n" % property.name
	if "class_name" in property:
		prop_str += 'class_name: &"%s"\n' % property.class_name
	if "type" in property:
		prop_str += "type: %s\n" % TYPE_STRINGS[property.type]
	if "hint" in property:
		prop_str += "hint: %s (%s)\n" % [
			property.hint,
			PROPERTY_HINT_STRINGS[property.hint]
		]
	if "hint_string" in property:
		prop_str += "hint_string: %s\n" % property.hint_string
	if "usage" in property:
		prop_str += "usage: %s (%s)" % [
			property.usage,
			", ".join(get_usage_flag_names(property.usage))
		]
	return prop_str

static func get_property(object: Object, name: StringName) -> Dictionary:
	var props := object.get_property_list()
	for p in props:
		if p.name == name:
			return p
	return {}

static func get_object_name(object: Object) -> String:
	if "name" in object:
		return object.name
	if "resource_name" in object:
		return object.resource_name
	return "Object"

static func get_object_class(object: Object) -> String:
	return object.get_class()

static func get_instantiate_property_editor_string(object: Object, name: StringName) -> String:
	var prop := get_property(object, name)
	return "\n".join([
		"EditorInterface.get_inspector().instantiate_property_editor(",
			"\t%s," % "get_edited_object()",
			"\t%s," % TYPE_STRINGS[prop.type],
			'\t"%s",' % name,
			"\t%s," % PROPERTY_HINT_STRINGS[prop.hint],
			'\t"%s",' % prop.hint_string,
			"\t%s," % " | ".join(get_usage_flag_names(prop.usage)),
		")"])

static func instantiate_property_editor(object: Object, name: String) -> EditorProperty:
	if !Engine.is_editor_hint():
		return
	var property := get_property(object, name)
	if property.is_empty():
		return null
	return instantiate_custom_property_editor(object, property)

static func instantiate_custom_property_editor(object: Object, property: Dictionary) -> EditorProperty:
	if !Engine.is_editor_hint():
		return
	return EditorInspector.instantiate_property_editor(
		object,
		property.type,
		property.name,
		property.hint,
		property.hint_string,
		property.usage
	)

func _init() -> void: assert(false, "Class can't be instantiated")
