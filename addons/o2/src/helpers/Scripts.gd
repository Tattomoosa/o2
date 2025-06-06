@tool

## Useful to get the script name for scripts that don't have `class_name`
static func get_object_script_name(object: Object) -> String:
	var script : Script = object.get_script()
	return get_script_name(script)

## Useful to get the script name for scripts that don't have `class_name`
static func get_script_name(script: Script) -> String:
	if !script: return ""
	var file := script.resource_path.get_file()
	var extension := file.get_extension()
	return file.replace(".%s" % extension, "")

## This used to be a lot harder! Probably can deprecate this
# TODO deprecate
static func get_object_class_name(object: Object) -> String:
	var script : Script = object.get_script()
	return get_script_class_name(script)

## This used to be a lot harder! Probably can deprecate this
# TODO deprecate
static func get_script_class_name(script: Script) -> String:
	if !script: return ""
	return script.get_global_name()

## Static class
func _init() -> void: assert(false, "Class can't be instantiated")
