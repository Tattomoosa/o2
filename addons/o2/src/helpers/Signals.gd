func _init() -> void:
	push_error("This is a static class and can't be instantiated")

static func swap(from: Object, to: Object, signal_name: StringName, callable: Callable) -> void:
	if from:
		var signal_a : Signal = from.get(signal_name)
		if signal_a.is_connected(callable):
			signal_a.disconnect(callable)
	if to:
		var signal_b : Signal = to.get(signal_name)
		if !signal_b.is_connected(callable):
			signal_b.connect(callable)
		