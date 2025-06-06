## Gets the bit value of a mask/flag int at a specific index
static func get_bit_value(mask: int, bit_index: int) -> bool:
	return mask & (1 << bit_index) != 0

## Returns a copy of a mask/flag with a bit set
static func with_bit_at(mask: int, bit_index: int) -> int:
	return mask | (1 << bit_index)

## Returns a copy of a mask/flag with a bit unset
static func without_bit_at(mask: int, bit_index: int) -> int:
	return mask & ~(1 << bit_index)

## Static class
func _init() -> void: assert(false, "Class can't be instantiated")
