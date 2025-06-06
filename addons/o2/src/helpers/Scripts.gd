@tool

static func get_object_script_name(object: Object) -> String:
	var script : Script = object.get_script()
	return get_script_name(script)

static func get_script_name(script: Script) -> String:
	if !script: return ""
	var file := script.resource_path.get_file()
	var extension := file.get_extension()
	return file.replace(".%s" % extension, "")

static func get_object_class_name(object: Object) -> String:
	var script : Script = object.get_script()
	return get_script_class_name(script)

static func get_script_class_name(script: Script) -> String:
	if !script: return ""
	return script.get_global_name()
	# lol
	# if script is GDScript:
	# 	var gd_script := script as GDScript
	# 	if gd_script in class_name_cache:
	# 		return class_name_cache[gd_script]
	# 	if !gd_script.has_source_code():
	# 		return ""
	# 	var source : String = gd_script.source_code
	# 	var regex := RegEx.new()
	# 	regex.compile(r"class_name (.*)\s")
	# 	var result := regex.search(source)
	# 	if result:
	# 		var script_class_name = result.get_string(1)
	# 		class_name_cache[gd_script] = script_class_name 
	# 		return script_class_name
	# return ""

func _init() -> void: assert(false, "Class can't be instantiated")
