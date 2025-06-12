@tool
@icon("uid://b5258mnsr6qim")
class_name O2
extends Node

const Logging := preload("uid://b5hb25ps522o0")
const TreeWatcher := preload("uid://c5n7icddagd25")
const EditorExtensions := preload("uid://bgceakmub8odv")
const LogLevel := Logging.LogLevel

static var instance : O2 = null

# maybe should be Logger since its static
# TODO actually thinking class_name L
static var logger : Logging.LogStream = Logging.LogStream.new(Logging.LogStream.LogLevel.DEBUG)

# could be a separate autoload but currently refcounted with view into node tree
# not designed to be talked to directy...
var _tree_watcher : TreeWatcher

func _init() -> void:
	if instance and is_instance_valid(instance): instance.queue_free()
	instance = self
	process_mode = Node.PROCESS_MODE_ALWAYS
	Logging.Handlers.LogToConsole.subscribe(logger)

func _ready() -> void:
	_tree_watcher = TreeWatcher.new(get_tree().root)

func _exit_tree() -> void:
	Logging.Handlers.LogToConsole.unsubscribe()