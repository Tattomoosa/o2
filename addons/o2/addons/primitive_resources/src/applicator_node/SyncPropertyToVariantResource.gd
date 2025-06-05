@tool
class_name SyncPropertyToVariantResource
extends Node

@export var resource : VariantResource:
	set(v):
		O2.Helpers.Signals.swap(resource, v, "changed", _update)
		resource = v
		if !resource:
			property_name = ""
			return
		notify_property_list_changed()
		_update()
@export var property_name : StringName:
	set(v):
		property_name = v
		notify_property_list_changed()
		_update()

func _ready() -> void:
	var parent := get_parent()
	if !parent.is_node_ready():
		await parent.ready
	_update()

		
func _update() -> void:
	var parent := get_parent()
	if !parent or !parent.is_node_ready():
		return
	if property_name and resource:
		if property_name in parent:
			get_parent().set(property_name, resource.value)
			name = "Sync%sTo%s" % [
				property_name.to_pascal_case(),
				(resource.resource_name.to_pascal_case()
						if resource.resource_name
						else O2.Helpers.Scripts.get_script_name(resource) 
				)
			]

func _validate_property(property: Dictionary) -> void:
	if property.name == "property_name":
		if !resource:
			property.usage = PROPERTY_USAGE_STORAGE
			return
		property.hint = PROPERTY_HINT_ENUM
		var hint_strings : Array[String] = []
		for parent_property in get_parent().get_property_list():
			if parent_property.type == resource.get_type():
				hint_strings.append(parent_property.name)
		property.hint_string = ",".join(hint_strings)