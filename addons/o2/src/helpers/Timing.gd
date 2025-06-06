## Was much more useful when this was a global TimeUtil class than calling it under O2.Helpers.Timing.wait lol
## Still useful to start a timer when you're somewhere outside of the tree.
static func wait(duration: float) -> void:
	await O2.get_tree().create_timer(duration).timeout

## Static class
func _init() -> void: assert(false, "Class can't be instantiated")

## Counts time, very accurately, from when it's instanced.
class Stopwatch extends RefCounted:
	var start_time : int
	var _use_usecs := false
	var elapsed : int:
		get: return get_elapsed()

	func _init(use_usecs := false) -> void:
		_use_usecs = use_usecs
		start_time = (
			Time.get_ticks_usec()
				if _use_usecs
				else Time.get_ticks_msec()
		)

	func get_elapsed() -> int:
		if _use_usecs:
			return Time.get_ticks_usec() - start_time
		else:
			return Time.get_ticks_msec() - start_time

	func get_elapsed_string() -> String:
		return "%d%s" % [
			elapsed,
			"us" if _use_usecs else "ms"
		]
	
	func get_elapsed_seconds() -> float:
		if _use_usecs:
			return elapsed / 1_000_000.0
		else:
			return elapsed / 1_000.0

## Counts frames from whenever it's instanced, either process (drawing) or physics
class FrameCounter extends RefCounted:
	var start_frame: int
	var _use_physics := false

	func _init(use_physics := false) -> void:
		_use_physics = use_physics
		start_frame = (
			Engine.get_physics_frames()
				if _use_physics
				else Engine.get_process_frames()
		)
	
	func get_frames() -> int:
		var frame := Engine.get_physics_frames() if _use_physics else Engine.get_process_frames()
		return frame - start_frame