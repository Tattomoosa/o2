@tool
@icon("uid://obguu32af2v")
class_name DictionaryTree
extends Tree

## Displays almost any arbitrary Dictionary as a Tree
## Only limitation is keys will only be represented as strings

@export var data : Dictionary
@export var key_title := "Key":
	set(v):
		key_title = v
		set_column_title(0, key_title)
@export var value_title := "Value":
	set(v):
		value_title = v
		set_column_title(1, value_title)

@export_group("JSON", "json_")
@export_multiline var json_string : String
@export_tool_button("Load") var json_load := load_json
@export_tool_button("Rebuild") var rebuild_button := _build

func _init() -> void:
	columns = 2
	set_column_title_alignment(0, HORIZONTAL_ALIGNMENT_LEFT)
	set_column_title_alignment(1, HORIZONTAL_ALIGNMENT_LEFT)
	set_column_clip_content(0, false)
	set_column_expand(0, true)
	set_column_expand(1, true)
	set_column_expand_ratio(0, 2)
	set_column_expand_ratio(1, 8)
	data = { "properties": get_property_list() }

func load_json(json := json_string) -> void:
	var result = JSON.parse_string(json)
	if result:
		data = result

func _ready() -> void:
	set_column_title(0, key_title)
	set_column_title(1, value_title)
	if data:
		_build()

func _build() -> void:
	clear()
	# root
	var root = create_item()
	_build_dictionary_item(root, data)

func _build_dictionary_item(parent: TreeItem, dictionary: Dictionary) -> void:
	for key in dictionary:
		var value : Variant = dictionary[key]
		var item := create_item(parent)
		item.set_text(0, str(key))
		_set_item_data(item, value)
			# item.set_text(1, str(value))

func _build_array_item(parent: TreeItem, array: Array) -> void:
	for i in array.size():
		var value : Variant = array[i]
		var item := create_item(parent)
		item.set_text(0, str(i))
		_set_item_data(item, value)

func _set_item_data(item: TreeItem, value: Variant) -> void:
	if value is Dictionary:
		item.set_text(1, "{}")
		_build_dictionary_item(item, value)
	elif H.Arrays.is_array(value):
		item.set_text(1, "[]")
		_build_array_item(item, value)
	else:
		item.set_text(1, str(value))