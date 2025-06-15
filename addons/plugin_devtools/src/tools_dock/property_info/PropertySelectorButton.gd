@tool
extends Button

signal property_selected(property: String)

func _pressed() -> void:
	var object := EditorInterface.get_inspector().get_edited_object()
	EditorInterface.popup_property_selector(
		object,
		_set_controls_to_property,
		[],
		"" # TODO 
	)

func _set_controls_to_property(path: NodePath) -> void:
	print(path)
	var property := str(path)
	var paths := property.split(":")
	print(paths)
	if paths.size() >= 2:
		# prints(paths[1], "(%s)" % paths)
		property_selected.emit(paths[1])
