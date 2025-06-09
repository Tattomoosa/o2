@tool
@icon("uid://b5258mnsr6qim")
class_name O2
extends Node

const Helpers := preload("uid://qle0x0d234xi")
const Logging := preload("uid://b5hb25ps522o0")
const TreeWatcher := preload("uid://c5n7icddagd25")

# maybe should be Logger since its static
static var logger : Logging.LogStream = Logging.LogStream.new()
# could be a separate autoload?
static var tree_watcher : TreeWatcher
static var instance : O2 = null

func _init() -> void:
	if instance and is_instance_valid(instance): instance.queue_free()
	instance = self
	process_mode = Node.PROCESS_MODE_ALWAYS
	Logging.Handlers.LogToConsole.subscribe(logger)

func _enter_tree() -> void:
	tree_watcher = TreeWatcher.new(get_tree().root)

func _exit_tree() -> void:
	Logging.Handlers.LogToConsole.unsubscribe()