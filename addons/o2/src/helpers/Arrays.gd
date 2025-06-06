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

## Array.find_custom, but also grabs the value
static func find_and_retrieve(array: Array, callable: Callable) -> Variant:
	var index := array.find_custom(callable)
	return array[index] if index >= 0 else null

## 'Static' class
func _init() -> void: assert(false, "Class can't be instantiated")
