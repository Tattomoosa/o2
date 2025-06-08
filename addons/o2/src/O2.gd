@tool
@icon("../assets/icons/o2.svg")
class_name O2
extends Node

const Helpers := preload("uid://qle0x0d234xi")
const Logging := preload("uid://dfhubnnkrv2jr")
const TreeWatcher := preload("uid://c5n7icddagd25")

var logger : Logging.LogStream = Logging.LogStream.new()
var tree_watcher : TreeWatcher

func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_connect_primary_logstream_to_console()

func _enter_tree() -> void:
	tree_watcher = TreeWatcher.new(get_tree().root)

func _connect_primary_logstream_to_console() -> void:
	Logging.Handlers.LogToConsole.subscribe(logger)
