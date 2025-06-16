@tool
extends CodeEdit

var property_info : String
var property_editor_code : String
var inspector : EditorInspector

func _ready() -> void:
	inspector = EditorInterface.get_inspector()
	inspector.property_selected.connect(_print_selected)
	inspector.edited_object_changed.connect(_edited_object_changed)
	# symbol_lookup.connect(_on_symbol_lookup)
	# symbol_validate.connect(_on_symbol_validate)

func _edited_object_changed() -> void:
	if !inspector.get_edited_object():
		text = ""

func _print_selected(property: String) -> void:
	var object := EditorInterface.get_inspector().get_edited_object()
	var property_info_dict := H.PropertyInfo.get_property(object, property)
	property_info = H.PropertyInfo.prettify(property_info_dict)
	property_editor_code = H.PropertyInfo.get_instantiate_property_editor_string(object, property)
	text = "# Property Info (_validate_property, _get_property_list):\n" +\
		property_info +\
		"\n\n# Instantiate EditorProperty (EditorInspectorPlugin)\n" +\
		"var property_editor := " + property_editor_code +\
		"\n" +\
		'add_property_editor("%s", property_editor)' % property

func _property_info_button_pressed() -> void:
	DisplayServer.clipboard_set(property_info)

func _property_editor_code_button_pressed() -> void:
	DisplayServer.clipboard_set(property_editor_code)

# func _on_symbol_lookup(string: String, line: int, column: int) -> void:
# 	pass

# func _on_symbol_validate(string: String) -> void:
# 	pass