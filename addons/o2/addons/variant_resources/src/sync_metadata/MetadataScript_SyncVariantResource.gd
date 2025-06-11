@tool
class_name MetadataScript_SyncVariantResource
extends MetadataScript

## Requires MetadataScript plugin

const Scripts := H.Scripts
const Signals := H.Signals

enum SyncMode {
	SyncResourceToProperty,
	BindProcess,
	BindPhysics,
}


@export var resource : VariantResource:
	set(v):
		H.Signals.swap(resource, v, "value_changed", _update)
		resource = v
		if Engine.is_editor_hint() and node:
			_patch_property_name_into_valid_property_enum()
			_update_resource_name()
		_update()

@export var property_name : StringName:
	set(v):
		property_name = v
		if Engine.is_editor_hint():
			_update_resource_name()
		_update()

@export var sync_mode := SyncMode.SyncResourceToProperty:
	set(value):
		sync_mode = value
		if !node:
			return
		if sync_mode != SyncMode.SyncResourceToProperty:
			_process_callback()

signal process_next_callback

var _property_name_property : Dictionary = {
	"hint": PROPERTY_HINT_ENUM_SUGGESTION,
	"hint_string": ""
}

func _process_callback() -> void:
	if !node or !is_instance_valid(node) or !node.is_inside_tree():
		return
	var v : Variant = node.get(property_name)
	if resource.value != v:
		resource.value = v
	match sync_mode:
		SyncMode.SyncResourceToProperty:
			return
		SyncMode.BindProcess:
			await node.get_tree().process_frame
		SyncMode.BindPhysics:
			await node.get_tree().physics_frame
	process_next_callback.emit()

func _update_resource_name() -> void:
	if resource and property_name:
		resource_name = "".join([
			"Sync",
			resource.resource_name if resource.resource_name else H.Scripts.get_script_name(resource.get_script()).replace("Resource", ""),
			"To",
			property_name.to_pascal_case()
		])

func _enter_tree() -> void:
	if Engine.is_editor_hint():
		_patch_property_name_into_valid_property_enum()
	_update()
	H.Signals.connect_if_not_connected(process_next_callback, _process_callback)
	if sync_mode != SyncMode.SyncResourceToProperty:
		_process_callback()

func _update() -> void:
	if !node:
		return
	if resource and property_name:
		node.set(property_name, resource.value)

# TODO this could probably just be handled by the InspectorPlugin...
func _validate_property(property: Dictionary) -> void:
	if !Engine.is_editor_hint():
		return
	super(property)
	if property.name == "property_name":
		property.hint = _property_name_property.hint
		property.hint_string = _property_name_property.hint_string

# TODO this could probably just be handled by the InspectorPlugin...
func _patch_property_name_into_valid_property_enum() -> void:
	var p := _property_name_property
	if node and resource:
		p.hint = PROPERTY_HINT_ENUM_SUGGESTION
		var hint_strings : Array[String] = []
		for property in node.get_property_list():
			if "name" in property and _can_sync_to_property(property):
				hint_strings.append(property.name)
		p.hint_string = ",".join(hint_strings)
	else:
		p.hint = PROPERTY_HINT_NONE
		p.hint_string = ""
	notify_property_list_changed()

func _can_sync_to_property(property: Dictionary) -> bool:
	if !property:
		return false
	if !H.BitMasks.get_bit_value(property.usage, PROPERTY_USAGE_NO_EDITOR):
		return false
	if resource is FlagsResource:
		return H.PropertyInfo.property_is_bitflags(property)
	return property.type == resource.get_type()
