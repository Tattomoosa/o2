@tool
@icon("../assets/icons/o2.svg")
extends Node

const Helpers := preload("helpers/index.gd")
const LogStream := preload("logger/LogStream.gd")

var Log : LogStream = LogStream.new()

func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_connect_primary_logstream_to_console()

func _connect_primary_logstream_to_console() -> void:
	Log.level = LogStream.LogLevel.DEBUG
	Log.logged_debug.connect(print_rich)
	Log.logged_info.connect(print_rich)
	Log.logged_warn.connect(push_warning)
	Log.logged_error.connect(push_error)