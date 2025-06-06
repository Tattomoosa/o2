@tool
class_name PropertySyncNode
extends Node

const ARRAY_PREFIX := "synced_properties_"
const PATH_SUFFIX := "node_path"
const PROPERTY_NAME_SUFFIX := "property_name"
const RESOURCE_SUFFIX := "resource"

@export var synced_properties_count := 0:
	set(v):
		synced_properties_count = v
		if is_node_ready() and synced_properties_count == 0:
			_synced_properties_names.clear()
			_synced_properties_resources.clear()
			_synced_properties_paths.clear()
		notify_property_list_changed()
@export_storage var _synced_properties_paths : Array[NodePath]
@export_storage var _synced_properties_resources : Array[VariantResource]
@export_storage var _synced_properties_names : Array[StringName]

var editor_array_helper : O2.Helpers.PropertyInfo.EditorArrayHelper

func _ready() -> void:
	editor_array_helper = O2.Helpers.PropertyInfo.EditorArrayHelper.new(
		self,
		"Synced Properties",
		"Add Synced Property",
		"synced_properties_count",
		ARRAY_PREFIX,
		{
			PATH_SUFFIX: _synced_properties_paths,
			RESOURCE_SUFFIX: _synced_properties_resources,
			PROPERTY_NAME_SUFFIX: _synced_properties_names
		}
	)
	editor_array_helper.array_changed.connect(_on_array_changed)
	editor_array_helper.array_about_to_change.connect(_on_array_about_to_change)
	for i in _synced_properties_resources.size():
		_synced_properties_resources[i].changed.connect(_update.bind(i))
		_update(i)

func _on_array_about_to_change(key: String, index: int) -> void:
	if key == RESOURCE_SUFFIX:
		var r : VariantResource = _synced_properties_resources[index]
		if !r: return
		if r.changed.is_connected(_update):
			r.changed.disconnect(_update)

func _on_array_changed(key: String, index: int) -> void:
	if key == RESOURCE_SUFFIX:
		var r : VariantResource = _synced_properties_resources[index]
		if !r: return
		if !r.changed.is_connected(_update):
			r.changed.connect(_update.bind(index))
			var node = _get_node(index)
			if !node or !_can_sync_to_property(
					r,
					O2.Helpers.PropertyInfo.get_property(
						node,
						_synced_properties_names[index]
					)):
				_synced_properties_names[index] = ""
	_update(index)

func _update(i: int) -> void:
	var resource := _synced_properties_resources[i]
	var node := _get_node(i)
	var property_name := _synced_properties_names[i]
	if resource and node and property_name:
		node.set(property_name, resource.get("value"))

func _get_node(index: int) -> Node:
	if _synced_properties_paths.size() > index:
		return get_node_or_null(_synced_properties_paths[index])
	return null

func _get_resource(index: int) -> VariantResource:
	if _synced_properties_resources.size() > index:
		return _synced_properties_resources[index]
	return null


func _validate_property(property: Dictionary) -> void:
	editor_array_helper.validate_property_helper(property)

func _get_property_list() -> Array[Dictionary]:
	var props := editor_array_helper.get_property_list_helper()
	for p in props:
		if p.name.ends_with(PROPERTY_NAME_SUFFIX):
			_patch_property_name_field_into_valid_property_enum(p)
	return props

func _patch_property_name_field_into_valid_property_enum(p: Dictionary) -> void:
	var i : int = p.name.to_int()
	var node := _get_node(i)
	var resource := _get_resource(i)
	if node and resource:
		p.hint = PROPERTY_HINT_ENUM_SUGGESTION
		var hint_strings : Array[String] = []
		for property in node.get_property_list():
			if _can_sync_to_property(resource, property):
				hint_strings.append(property.name)
		p.hint_string = ",".join(hint_strings)

func _can_sync_to_property(resource: VariantResource, property: Dictionary) -> bool:
	if !property:
		return false
	if resource is FlagsResource:
		return O2.Helpers.PropertyInfo.property_is_bitflags(property)
	return property.type == resource.get_type()

func _get(property: StringName) -> Variant:
	return editor_array_helper.get_helper(property)

func _set(property: StringName, value: Variant) -> bool:
	if editor_array_helper:
		return editor_array_helper.set_helper(property, value)
	return false
