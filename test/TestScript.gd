@tool
class_name TestScript
extends Node

func _ready() -> void:
	var sw := O2.Helpers.Timers.Stopwatch.new()
	var frames := O2.Helpers.Timers.FrameCounter.new()
	await O2.Helpers.Timers.wait(1.0)
	prints(sw.get_elapsed_seconds(), frames.get_frames())
