@tool
extends O2.EditorExtensions.InspectorPlugin

const VariantResourceEditorProperty := preload("VariantResourceEditorProperty.gd")
const InspectorPlugin := preload("VariantResourceInspector.gd")
const Controls := H.Controls
const ES := o2.EditorExtensions.Settings

const TYPE_MAP : Dictionary[Variant.Type, String] = {
	TYPE_BOOL: "BoolResource",
	TYPE_INT: "IntResource",
	TYPE_FLOAT: "FloatResource",
	TYPE_STRING: "StringResource",
	TYPE_VECTOR2: "Vector2Resource",
	TYPE_VECTOR2I: "Vector2iResource",
	TYPE_VECTOR3: "Vector3Resource",
	TYPE_VECTOR3I: "Vector3iResource",
	TYPE_TRANSFORM2D: "Transform2DResource",
	TYPE_VECTOR4: "Vector4Resource",
	TYPE_VECTOR4I: "Vector4iResource",
	TYPE_PLANE: "PlaneResource",
	TYPE_QUATERNION: "QuaternionResource",
	TYPE_AABB: "AABBResource",
	TYPE_BASIS: "BasisResource",
	TYPE_TRANSFORM3D: "Transform3DResource",
	TYPE_PROJECTION: "ProjectionResource",
	TYPE_COLOR: "ColorResource",
	TYPE_STRING_NAME: "StringNameResource",
	TYPE_NODE_PATH: "NodePathResource",
	# TYPE_DICTIONARY: "DictionaryResource",
	# TYPE_ARRAY: "ArrayResource",
	TYPE_PACKED_BYTE_ARRAY: "PackedByteArrayResource",
	TYPE_PACKED_INT32_ARRAY: "PackedInt32ArrayResource",
	TYPE_PACKED_INT64_ARRAY: "PackedInt64ArrayResource",
	TYPE_PACKED_FLOAT32_ARRAY: "PackedFloat32ArrayResource",
	TYPE_PACKED_FLOAT64_ARRAY: "PackedFloat64ArrayResource",
	TYPE_PACKED_STRING_ARRAY: "PackedStringArrayResource",
	TYPE_PACKED_VECTOR2_ARRAY: "PackedVector2ArrayResource",
	TYPE_PACKED_VECTOR3_ARRAY: "PackedVector3ArrayResource",
	TYPE_PACKED_COLOR_ARRAY: "PackedColorArrayResource",
	TYPE_PACKED_VECTOR4_ARRAY: "PackedVector4ArrayResource",
}

func _can_handle(_object: Object) -> bool:
	return true

func parse_property(object: Object, type: Variant.Type, name: String, hint_type: PropertyHint, hint_string: String, _usage_flags: int, _wide: bool) -> bool:
	if !name:
		return false
	if type == TYPE_OBJECT and hint_type == PROPERTY_HINT_RESOURCE_TYPE:
		if !H.Scripts.is_class_name(hint_string):
			return false
		if !H.Scripts.class_name_extends_from(hint_string, "VariantResource"):
			return false
		add_property_editor(name, _create_resource_editor(object, name))
		# add_context_menu_item(object, name, "Paste Into %s Value" % hint_string, _paste_into_resource_value)
		# add_context_menu_item(object, name, "Copy %s Value" % hint_string, _copy_from_resource_value)
		return true
	return false

# TODO https://github.com/godotengine/godot-proposals/issues/8745
# Or implement my own... :/
func _paste_into_resource_value(_ep: EditorProperty) -> void:
	pass

func _copy_from_resource_value(_ep: EditorProperty) -> void:
	pass

func _create_resource_editor(object: Object, property_name: String) -> EditorProperty:
	var property := PropertyInfo.get_property(object, property_name)
	var resource_editor : VariantResourceEditorProperty = instantiate_patched_property_editor(
		object,
		property,
		VariantResourceEditorProperty
	)
	resource_editor.inspector_plugin = self
	var resource : VariantResource = object.get(property_name)
	if resource:
		resource_editor.property_definition = PropertyInfo.get_property(resource, "value")
	else:
		resource_editor.property_definition = property
	return resource_editor