@tool
extends Node

const Helpers := preload("helpers/index.gd")
const LogStream := preload("logger/LogStream.gd")

var Log : LogStream = LogStream.new()

func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	Log.level = LogStream.LogLevel.DEBUG
	Log.logged_debug.connect(print_rich)
	Log.logged_info.connect(print_rich)
	Log.logged_warn.connect(push_warning)
	Log.logged_error.connect(push_error)
