@tool
extends CodeEdit

var property_info : String
var property_editor_code : String

func _ready() -> void:
	EditorInterface.get_inspector().property_selected.connect(_print_selected)
	symbol_lookup.connect(_on_symbol_lookup)
	symbol_validate.connect(_on_symbol_validate)

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
	# sym

func _on_symbol_lookup(string: String, line: int, column: int) -> void:
	pass

func _on_symbol_validate(string: String) -> void:
	pass