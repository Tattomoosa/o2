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
		disconnect_if_connected(signal_a, callable)
	if to:
		var signal_b : Signal = to.get(signal_name)
		connect_if_not_connected(signal_b, callable, flags)

static func connect_if_not_connected(p_signal: Signal, callable: Callable, flags: int = 0) -> void:
	if !p_signal.is_connected(callable):
		var result := p_signal.connect(callable, flags)
		if result != OK:
			push_warning(error_string(result))

static func disconnect_if_connected(p_signal: Signal, callable: Callable) -> void:
	if p_signal.is_connected(callable):
		p_signal.disconnect(callable)
	
		
func _init() -> void: assert(false, "Class can't be instantiated")