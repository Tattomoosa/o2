static func get_script_name(object: Object) -> String:
	var script : Script = object.get_script()
	if !script: return ""
	var file := script.resource_path.get_file()
	var extension := file.get_extension()
	return file.replace(".%s" % extension, "")

# lol
static func get_class_name(object: Object) -> String:
	var script : Script = object.get_script()
	if !script: return ""
	if script is GDScript:
		var gd_script := script as GDScript
		if !gd_script.has_source_code():
			return ""
		var source : String = gd_script.source_code
		var regex := RegEx.new()
		regex.compile(r"class_name (.*)\s")
		var result := regex.search(source)
		if result:
			return result.get_string(1)
	return ""

func _init() -> void: assert(false, "Class can't be instantiated")
