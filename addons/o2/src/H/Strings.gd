static func ends_with_any(string: String, suffixes: Array[String]) -> bool:
	for suffix in suffixes:
		if string.ends_with(suffix):
			return true
	return false

static func begins_with_any(string: String, suffixes: Array[String]) -> bool:
	for suffix in suffixes:
		if string.ends_with(suffix):
			return true
	return false

# TODO support numbers, should match what godot does
static func to_title_cased_spaced(string: String) -> String:
	string = string.to_pascal_case()
	var re := RegEx.new()
	re.compile(r"[A-Z0-9][a-z]*")
	var result := re.search_all(string)
	var split_string := []
	for match in result:
		split_string.push_back(match.get_string())
	return " ".join(split_string)

## Static class
func _init() -> void: assert(false, "Class can't be instantiated")