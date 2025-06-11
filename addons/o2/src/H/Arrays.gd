## Array.reversed, but returns a new array
static func reversed(array: Array) -> Array:
	var a := array.duplicate()
	a.reverse()
	return a

## Array.shuffle, but returns a new array
static func shuffled(array: Array) -> Array:
	var a := array.duplicate()
	a.shuffle()
	return a

static func swap(array: Array, from: int, to: int) -> void:
	var a = array[from]
	var b = array[to]
	array[to] = a
	array[from] = b

## Array.find_custom, but also grabs the value
static func find_and_get(array: Array, callable: Callable) -> Variant:
	var index := array.find_custom(callable)
	return array[index] if index >= 0 else null

static func get_first_dictionary_matching_property(array: Array, key: String, value: Variant) -> Dictionary:
	var dict : Variant = find_and_get(
		array,
		func(x):
			return x is Dictionary and key in x and x[key] == value
	)
	if dict == null: return {}
	return dict


## 'Static' class
func _init() -> void: assert(false, "Class can't be instantiated")
