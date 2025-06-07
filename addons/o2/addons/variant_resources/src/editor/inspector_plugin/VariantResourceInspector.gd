extends EditorInspectorPlugin

func _can_handle(_object: Object) -> bool:
	return true

func _parse_property(object: Object, type: Variant.Type, name: String, hint_type: PropertyHint, hint_string: String, _usage_flags: int, _wide: bool) -> bool:
	if type == TYPE_OBJECT and hint_type == PROPERTY_HINT_RESOURCE_TYPE:
		if object is FakeNode:
			return false
		add_property_editor(name, _create_resource_editor(hint_string, name, object))
		return true
	return false

func _create_resource_editor(resource_type: String, property_name: String, object: Object) -> EditorProperty:
	var resource_editor = EditorInspector.instantiate_property_editor(
		FakeNode.new(), # LOL
		# object,
		TYPE_OBJECT,
		property_name,
		PROPERTY_HINT_RESOURCE_TYPE,
		resource_type,
		PROPERTY_USAGE_DEFAULT\
				| PROPERTY_USAGE_STORAGE\
				| PROPERTY_USAGE_EDITOR\
				| PROPERTY_USAGE_SCRIPT_VARIABLE,
	)
	resource_editor.set_object_and_property(object, property_name)
	resource_editor.update_property()
	var resource_picker : EditorResourcePicker = resource_editor.get_child(0)
	var resource_button := resource_picker.get_child(0)

	var vbox := VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	resource_picker.resource_changed.connect(
		_on_resource_changed.bind(resource_editor)
	)
	resource_picker.add_child(vbox, false, Node.INTERNAL_MODE_FRONT)
	resource_button.reparent(vbox, false)
	_populate_exposed_resource_properties(object.get(property_name), vbox, resource_button)
	
	return resource_editor

func _on_resource_changed(resource: Resource, editor_property: EditorProperty) -> void:
	pass
	# print("resource changed")

func _populate_exposed_resource_properties(
	resource: Resource,
	vbox: VBoxContainer,
	resource_button: Button,
) -> void:
	# print("running populate exposed resource properties")
	for child in vbox.get_children(true):
		if child != resource_button:
			# print("found child!")
			child.queue_free()
	if !resource:
		return
	for property in resource.get_property_list():
		if property.name == "value":
			var property_editor := EditorInspector.instantiate_property_editor(
				resource,
				property.type,
				property.name,
				property.hint,
				property.hint_string if property.hint_string else "",
				property.usage,
			)
			property_editor.label = property.name
			property_editor.set_object_and_property(resource, property.name)
			property_editor.name_split_ratio = 0.3
			property_editor.property_changed.connect(
				func(property_name: StringName, value: Variant, _field: StringName, _changing: bool) -> void:
					if value is Color: print("COLOR!")
					resource.set(property_name, value)
					property_editor.update_property()
			)
			# if resource.changed.is_connected(_populate_exposed_resource_properties):
				# resource.changed.disconnect(_populate_exposed_resource_properties)
				# resource.changed.connect(_populate_exposed_resource_properties.bind(resource, vbox, resource_button))
			# if !resource.property_list_changed.is_connected(_populate_exposed_resource_properties):
				# resource.property_list_changed.disconnect(_populate_exposed_resource_properties)
				# resource.property_list_changed.connect(_populate_exposed_resource_properties.bind(resource, vbox, resource_button))
			resource.value_changed.connect(property_editor.update_property)
			property_editor.update_property()
			vbox.add_child(property_editor)
			return

# LOL
class FakeNode extends Node:
	pass