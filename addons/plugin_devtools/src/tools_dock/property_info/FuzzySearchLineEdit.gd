@tool
extends LineEdit

signal search_results(matches: PackedStringArray)

@export var data : PackedStringArray

func _ready() -> void:
	text_changed.connect(_search)

func _search(new_text: String) -> void:
	var matches := H.Search.FuzzySearch.search(new_text, data)
	print(matches)
	search_results.emit(matches)