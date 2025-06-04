static func get_bit_value(mask: int, bit_index: int) -> bool:
	return mask & (1 << bit_index) != 0

static func with_bit_at(mask: int, bit_index: int) -> int:
	return mask | (1 << bit_index)

static func without_bit_at(mask: int, bit_index: int) -> int:
	return mask & ~(1 << bit_index)