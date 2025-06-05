@tool
extends EditorPlugin

var inspector_plugin := ExposedResourcePropertyEditorInspectorPlugin.new()

func _enable_plugin() -> void:
	# Add autoloads here.
	pass


func _disable_plugin() -> void:
	# Remove autoloads here.
	pass


func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	add_inspector_plugin(inspector_plugin)


func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	remove_inspector_plugin(inspector_plugin)


# TODO Color doesn't work!
class ExposedResourcePropertyEditorInspectorPlugin extends EditorInspectorPlugin:

	func _can_handle(_object: Object) -> bool:
		return true

	func _parse_property(object: Object, type: Variant.Type, name: String, hint_type: PropertyHint, hint_string: String, _usage_flags: int, _wide: bool) -> bool:
		if type == TYPE_OBJECT and hint_type == PROPERTY_HINT_RESOURCE_TYPE:
			if object is FakeNode:
				return false
			add_property_editor(name, _create_resource_editor(hint_string, name, object))
			return true
		return false
	
	func _create_resource_editor(resource_type: String, name: String, object: Object) -> EditorProperty:
		var resource_editor = EditorInspector.instantiate_property_editor(
			FakeNode.new(), # LOL
			TYPE_OBJECT,
			name,
			PROPERTY_HINT_RESOURCE_TYPE,
			resource_type,
			PROPERTY_USAGE_DEFAULT\
					| PROPERTY_USAGE_STORAGE\
					| PROPERTY_USAGE_EDITOR\
					| PROPERTY_USAGE_SCRIPT_VARIABLE,
		)
		resource_editor.set_object_and_property(object, name)
		resource_editor.update_property()
		var resource_picker : EditorResourcePicker = resource_editor.get_child(0)
		var resource_button := resource_picker.get_child(0)

		var vbox := VBoxContainer.new()
		vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		resource_picker.resource_changed.connect(
			_populate_exposed_resource_properties.bind(resource_button).bind(vbox)
		)
		_populate_exposed_resource_properties(object.get(name), vbox, resource_button)
		resource_editor.property_can_revert_changed.connect(
			func(_property: StringName, _can_revert: bool) -> void:
				_populate_exposed_resource_properties(object.get(name), vbox, resource_button)
		)
		resource_editor.editor_state_changed.connect(
			func() -> void:
				_populate_exposed_resource_properties(object.get(name), vbox, resource_button)
		)
		# resource_editor.property_changed.connect(
		# 	func(_property_name: StringName, _value: Variant, _field: StringName, _changing: bool) -> void:
		# 		_populate_exposed_resource_properties(object.get(name), vbox, resource_button)
		# )
		resource_picker.add_child(vbox, false, Node.INTERNAL_MODE_FRONT)
		resource_button.reparent(vbox, false)
		
		return resource_editor

	func _populate_exposed_resource_properties(
		resource: Resource,
		vbox: VBoxContainer,
		resource_button: Button,
	) -> void:
		for child in vbox.get_children():
			if child != resource_button:
				child.queue_free()
		if !resource:
			return
		for property in resource.get_property_list():
			if property.hint_string == "expose_value":
				var property_editor := EditorInspector.instantiate_property_editor(
					resource,
					property.type,
					property.name,
					property.hint,
					"",
					# property.usage,
					PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_STORAGE | PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_SCRIPT_VARIABLE,
					false
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
				resource.changed.connect(property_editor.update_property)
				property_editor.update_property()
				vbox.add_child(property_editor)


# LOL
class FakeNode extends Node:
	pass