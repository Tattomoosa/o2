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

static func to_title_cased_spaced(string: String) -> String:
	string = string.to_pascal_case()
	var re := RegEx.new()
	re.compile(r"[A-Z]")
	var result := re.search_all(string)
	var split_string := []
	for i in result.size():
		var match := result[i]
		var start := match.get_start()
		var next := result[i + 1].get_start() if result.size() > (i + 1) else -1
		split_string.push_back(string.substr(start, next)
		)
	return " ".join(split_string)

## Static class
func _init() -> void: assert(false, "Class can't be instantiated")