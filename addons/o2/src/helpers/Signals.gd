## The most useful function for dealing with resource properties, ever!
##
## ``` gdscript
## @export var resource : SomeResource:
## 	 set(v):
##		 O2.Helpers.Signals.swap(resource, v, "changed", _on_changed)
##     resource = v
## ```
static func swap(from: Object, to: Object, signal_name: StringName, callable: Callable, flags: int = 0) -> void:
	if from:
		var signal_a : Signal = from.get(signal_name)
		if signal_a.is_connected(callable):
			signal_a.disconnect(callable)
	if to:
		var signal_b : Signal = to.get(signal_name)
		if !signal_b.is_connected(callable):
			var result := signal_b.connect(callable, flags)
			if result != OK:
				push_warning(error_string(result))
		
func _init() -> void: assert(false, "Class can't be instantiated")