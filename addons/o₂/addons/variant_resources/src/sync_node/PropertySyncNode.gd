@tool
class_name PropertySyncNode
extends Node

const PropertyInfo := H.PropertyInfo
const EditorArrayGroupHelper := H.Editor.ArrayGroupHelper

const ARRAY_PREFIX := "synced_properties_"
const PATH_SUFFIX := "node_path"
const PROPERTY_NAME_SUFFIX := "property_name"
const RESOURCE_SUFFIX := "resource"

# TODO see if I can also move handling this into the EditorArrayHelper
@export var synced_properties_count := 0:
	set(v):
		synced_properties_count = v
		if is_node_ready() and synced_properties_count == 0:
			_synced_properties_names.clear()
			_synced_properties_paths.clear()
			_synced_properties_resources.clear()
		notify_property_list_changed()
@export_storage var _synced_properties_paths : Array[NodePath]
@export_storage var _synced_properties_names : Array[StringName]
@export_storage var _synced_properties_resources : Array[VariantResource]

var _synced_properties_callables : Array[Callable]

var editor_array_helper : EditorArrayGroupHelper

func _ready() -> void:
	editor_array_helper = EditorArrayGroupHelper.new(
		self,
		"Synced Properties",
		"Add Synced Property",
		"synced_properties_count",
		ARRAY_PREFIX,
		{
			PATH_SUFFIX: _synced_properties_paths,
			PROPERTY_NAME_SUFFIX: _synced_properties_names,
			RESOURCE_SUFFIX: _synced_properties_resources,
		}
	)
	editor_array_helper.array_changed.connect(_on_array_changed)
	editor_array_helper.array_about_to_change.connect(_on_array_about_to_change)
	for i in _synced_properties_resources.size():
		var r := _get_resource(i)
		if r: r.value_changed.connect(_get_callable(i))
		_update(i)

func _on_array_about_to_change(key: String, index: int) -> void:
	if key == RESOURCE_SUFFIX:
		var r : VariantResource = _synced_properties_resources[index]
		if !r: return
		var callable := _get_callable(index)
		if r.value_changed.is_connected(callable):
			r.value_changed.disconnect(callable)

func _on_array_changed(key: String, index: int) -> void:
	if key == RESOURCE_SUFFIX:
		var r : VariantResource = _synced_properties_resources[index]
		if !r: return
		var callable := _get_callable(index)
		if !r.value_changed.is_connected(callable):
			r.value_changed.connect(callable)
			var node = _get_node(index)
			var property_name := _synced_properties_names[index]
			if !node or !_can_sync_to_property(r, PropertyInfo.get_property(node, property_name)):
				_synced_properties_names[index] = ""
	_update(index)

func _update(i: int) -> void:
	var resource := _get_resource(i)
	var node := _get_node(i)
	var property_name := _get_property_name(i)
	if resource and node and property_name:
		node.set(property_name, resource.get("value"))

func _get_property_name(index: int) -> StringName:
	if _synced_properties_names.size() > index:
		return _synced_properties_names[index]
	return ""

func _get_node(index: int) -> Node:
	if _synced_properties_paths.size() > index:
		return get_node_or_null(_synced_properties_paths[index])
	return null

func _get_resource(index: int) -> VariantResource:
	if _synced_properties_resources.size() > index:
		return _synced_properties_resources[index]
	return null

# Need to use/store anonymous functions so we can connect/disconnect from the same signal multiple times
# Maybe possible with CONNECT_REFERENCE_COUNTED, but this seems less error-prone since we can check
# connections and don't need to know what other indexes are doing or if the resource has changed or
# anything
func _get_callable(index: int) -> Callable:
	for i in range(_synced_properties_callables.size(), index + 1):
		_synced_properties_callables.push_back(func(): _update(i))
	return _synced_properties_callables[index]

func _validate_property(property: Dictionary) -> void:
	if editor_array_helper:
		editor_array_helper.validate_property_helper(property)

func _get_property_list() -> Array[Dictionary]:
	if !editor_array_helper:
		return [{}]
	var props := editor_array_helper.get_property_list_helper()
	for p in props:
		if p.name.ends_with(PROPERTY_NAME_SUFFIX):
			_patch_property_name_field_into_valid_property_enum(p)
	return props

# TODO this could probably just be handled by the InspectorPlugin
func _patch_property_name_field_into_valid_property_enum(p: Dictionary) -> void:
	var i : int = p.name.to_int()
	var node := _get_node(i)
	var resource := _get_resource(i)
	if node and resource:
		p.usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE
		p.hint = PROPERTY_HINT_ENUM_SUGGESTION
		var hint_strings : Array[String] = []
		for property in node.get_property_list():
			if _can_sync_to_property(resource, property):
				hint_strings.append(property.name)
		p.hint_string = ",".join(hint_strings)
	else:
		p.usage = PROPERTY_USAGE_NONE

# TODO this could probably just be handled by the InspectorPlugin
func _can_sync_to_property(resource: VariantResource, property: Dictionary) -> bool:
	if !property:
		return false
	if resource is FlagsResource:
		return PropertyInfo.property_is_bitflags(property)
	return property.type == resource.get_type()

func _get(property: StringName) -> Variant:
	if is_node_ready():
		return editor_array_helper.get_helper(property)
	return null

func _set(property: StringName, value: Variant) -> bool:
	if editor_array_helper:
		return editor_array_helper.set_helper(property, value)
	return false
