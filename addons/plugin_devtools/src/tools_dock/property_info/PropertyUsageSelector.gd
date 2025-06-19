@tool
extends Container

signal usage_changed(usage: int)

const USAGES := H.PropertyInfo.USAGE_FLAG_STRINGS

var usages := PackedStringArray()
var fake_object := FakeResource.new()
var flags : int = 6
var EXCLUDE_LIST := [
	PROPERTY_USAGE_CHECKABLE,
	PROPERTY_USAGE_CHECKED,
	PROPERTY_USAGE_GROUP,
	PROPERTY_USAGE_SUBGROUP,
	PROPERTY_USAGE_CATEGORY,
]

func _ready() -> void:
	if is_part_of_edited_scene():
		return
	fake_object.changed.connect(_on_object_changed)
	usages = []
	for usage in USAGES:
		if usage in EXCLUDE_LIST:
			continue
		var usage_string := USAGES[usage]
		usage_string = usage_string.replace("PROPERTY_USAGE_", "")
		usage_string += ":%d" %  usage
		usages.push_back(usage_string)
	_update()

func _on_object_changed() -> void:
	prints("object changed ", fake_object.usage)
	# if fake_object.property
	# fake_object.usage = PROPERTY_USAGE_DEFAULT
	usage_changed.emit(fake_object.usage)

func _on_property_changed(_property: StringName, value: Variant, _field: StringName, _changing: bool) -> void:
	# prints("property changed: ", value)
	fake_object.usage = value

func _update() -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()
	var ep := H.PropertyInfo.instantiate_custom_property_editor(fake_object, {
		"name": "usage",
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_FLAGS,
		"hint_string": ",".join(usages),
		"usage": PROPERTY_USAGE_DEFAULT,
	})
	ep.set_object_and_property(fake_object, "usage")
	ep.property_changed.connect(_on_property_changed)
	ep.name_split_ratio = 0.0
	ep.update_property()
	add_child(ep)

class FakeResource extends Resource:
	var usage : int = 0:
		set(v):
			usage = v
			emit_changed()