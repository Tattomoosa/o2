@tool

const _BitMasks := O2.Helpers.BitMasks

## Converts from a usage flag bit to the corresponding string
## Note that PROPERTY_USAGE_DEFAULT is just PROPERTY_USAGE_STORAGE | PROPERTY_USAGE_EDITOR
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

## To convert from a Variant.Type enum to the corresponding string -- NOT the same as type_string()
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

## To convert from a Variant.Type enum to the corresponding string -- NOT the same as type_string()
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

## Takes a property.usage bitflag int and prints all the flags
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

## Gets a Variant.Type constant name -- not the "human readable" name from type_string()!
static func get_type_name(type: int) -> StringName:
	return TYPE_STRINGS[type]

## Gets a property hint enum name
static func get_property_hint_name(property_hint: int) -> StringName:
	# print("property_hint: ", property_hint)
	return PROPERTY_HINT_STRINGS[property_hint]

## Pretty prints an object property (Dictionary definition returns from get_property_list())
static func prettify(property: Dictionary) -> String:
	var prop_str := "[ Property Info: '%s' ]\n" % property.name
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
		prop_str += "hint_string: "
		if property.hint == PROPERTY_HINT_TYPE_STRING:
			prop_str += "%s (\"%s\")\n" % [
				parse_hint_type_string(property.hint_string),
				property.hint_string,
			]
		else:
			prop_str += "%s\n" % property.hint_string
	if "usage" in property:
		prop_str += "usage: %s (%s)" % [
			property.usage,
			", ".join(get_usage_flag_names(property.usage))
		]
	return prop_str

## PROPERTY_HINT_TYPE_STRING is especially hairy, this tells you what it's doing and is... 
## probably mostly correct?
# TODO Needs a lot of testing I haven't done
static func parse_hint_type_string(t_string: String) -> String:
	var parsed_str := ""
	var regex := RegEx.new()
	regex.compile(r"^((?:\d+\d*[\/]*\d*:;?)+)(\S*)$")
	var result := regex.search(t_string)
	if result:
		# last one is hint string
		var count := result.get_group_count()
		if count != 2:
			print_debug("huh", result)
		var section0 := result.get_string(1)
		var type_data := (
			Array(section0.split(":"))
				.filter(func(x): return !x.is_empty())
		)
		if ";" in section0:
			parsed_str += "{ "
		for t in type_data:
			if "/" not in t:
				parsed_str += get_type_name(t.to_int())
				parsed_str += " : "
				continue
			else:
				t = t.split("/")
				parsed_str += get_type_name(t[0].to_int())
				parsed_str += "/"
				parsed_str += get_property_hint_name(t[1].to_int())
				if ";" in t[0]:
					parsed_str += " } : "
				else:
					parsed_str += " : "
		var hint_string := result.get_string(2)
		parsed_str += "'%s'" % hint_string
		return parsed_str
	return "???"

## PROPERTY_HINT_TYPE_STRING is especially hairy, this helps you construct it
static func construct_array_hint_type_string(
	types: Array[Variant.Type],
	usages: Array,
	hint_string : String
) -> String:
	var hint_str := ""
	for i in types.size():
		hint_str += str(types[i])
		if usages[i] > 0:
			hint_str += "/%d" % usages[i]
		hint_str += ":"
	hint_str += hint_string
	return hint_str
		
## Gets a property definition, like those returned from get_property_list(), but just one by name
static func get_property(object: Object, name: StringName) -> Dictionary:
	if !object:
		push_error("object is null")
	var props := object.get_property_list()
	for p in props:
		if p.name == name:
			return p
	return {}

## Generic way to just get a human-readable name from an object
static func get_object_name(object: Object) -> String:
	if "name" in object:
		return object.name
	if "resource_name" in object:
		return object.resource_name
	return "Object"

# TODO this is useless now that PropertyInfo can do it better itself
# @deprecated
static func get_instantiate_property_editor_string(object: Object, name: StringName) -> String:
	var prop := get_property(object, name)
	return "\n".join([
		"EditorInspector.instantiate_property_editor(",
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

## Whether or not a given int property is bitflags
static func property_is_bitflags(property: Dictionary) -> bool:
		return (
			(
				"usage" in property
				and _BitMasks.get_bit_value(
					property.usage, PROPERTY_USAGE_CLASS_IS_BITFIELD
				)
			)
			or property.hint in [
				PROPERTY_HINT_FLAGS,
				PROPERTY_HINT_LAYERS_2D_RENDER,
				PROPERTY_HINT_LAYERS_2D_PHYSICS,
				PROPERTY_HINT_LAYERS_2D_NAVIGATION,
				PROPERTY_HINT_LAYERS_3D_RENDER,
				PROPERTY_HINT_LAYERS_3D_PHYSICS,
				PROPERTY_HINT_LAYERS_3D_NAVIGATION,
				PROPERTY_HINT_LAYERS_AVOIDANCE,
			]
		)

## Helper to make an "EditorArray" - or something that shows up in the inspector like a single
## group of properties in a list, but is actually backed by multiple data arrays holding associated
## data in each index. Useful when you don't want to make a Resource and deal with local_to_scene
## just to make a nice inspector, plus it's a little easier to use than an Array[Resource]
##
## Unfortunately, given the limitations, it is a bit hairy to setup. See PropertySyncNode for 
## an example. Real documentation someday... maybe.
class EditorArrayHelper extends RefCounted:
	var object: Object
	var count_property_name : StringName
	var display_name : String
	var add_button_text : String
	var prefix : String
	var typed_data_arrays : Dictionary[String, Array]

	signal array_about_to_change(key: String, index: int)
	signal array_changed(key: String, index: int)

	func _init(
		p_object: Object,
		p_display_name: String,
		p_add_button_text: String,
		p_count_property_name: StringName,
		p_prefix: String,
		p_typed_data_arrays: Dictionary[String, Array],
	) -> void:
		object = p_object
		display_name = p_display_name
		count_property_name = p_count_property_name
		prefix = p_prefix
		typed_data_arrays = p_typed_data_arrays
		add_button_text = p_add_button_text
		for array in typed_data_arrays.values():
			assert(array.is_typed(), "Arrays must have a defined type")

	func validate_property_helper(property: Dictionary) -> void:
		if property.name == count_property_name:
			property.class_name = ",".join([
				display_name,
				prefix,
				"unfoldable",
				"page_size=999",
				"add_button_text=" + add_button_text
			])
			property.usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_ARRAY

	func get_property_list_helper() -> Array[Dictionary]:
		var props : Array[Dictionary] = []
		# TODO figure out how to make each one foldable?
		# for i in object.get(count_property_name):
		# 	var prop := {}
		# 	prop.type = TYPE_NIL
		# 	prop.usage = PROPERTY_USAGE_GROUP
		# 	prop.hint_string = prefix
		# 	prop.name = "%s %d" % [display_name, i]
		# 	props.push_back(prop)
		for key in typed_data_arrays:
			var array := typed_data_arrays[key]
			var prop := {}
			prop.type = array.get_typed_builtin()
			prop.usage = PROPERTY_USAGE_EDITOR
			if prop.type == TYPE_OBJECT:
				var c_name := array.get_typed_class_name()
				# TODO probably a bunch of these that need to be covered
				if c_name == "Resource":
					prop.hint = PROPERTY_HINT_RESOURCE_TYPE
				var script : Script = array.get_typed_script()
				var script_class_name := script.get_global_name()
				if script_class_name:
					prop.hint_string = script_class_name
			for i in object.get(count_property_name):
				var p := prop.duplicate()
				p.name = prefix + str(i) + "/" + key
				props.push_back(p)
		return props
	
	func get_helper(property: StringName) -> Variant:
		if property.begins_with(prefix):
			var i := property.to_int()
			for key in typed_data_arrays:
				if property.ends_with(key):
					var arr := typed_data_arrays[key]
					if arr.size() <= i:
						arr.resize(i + 1)
					return typed_data_arrays[key][i]
		return null
	
	func set_helper(property: StringName, value: Variant) -> bool:
		if property.begins_with(prefix):
			var i := property.to_int()
			for key in typed_data_arrays:
				if property.ends_with(key):
					if "is_node_ready" in object:
						if !object.is_node_ready():
							return true
					var arr := typed_data_arrays[key]
					arr.resize(object.get(count_property_name))
					array_about_to_change.emit(key, i)
					typed_data_arrays[key][i] = value
					array_changed.emit(key, i)
					object.notify_property_list_changed()
					return true
		return false

func _init() -> void: assert(false, "Class can't be instantiated")
