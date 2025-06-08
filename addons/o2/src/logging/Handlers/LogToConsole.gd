@tool

const LogStream := preload("uid://kj2lij0iyp3h")

static var _stream : LogStream

static func subscribe(stream: LogStream) -> void:
	assert(_stream == null)
	_stream = stream
	_subscribe(_stream)

static func _subscribe(stream: LogStream) -> void:
	stream.logged_debug.connect(print_rich)
	stream.logged_info.connect(print_rich)
	stream.logged_warn.connect(push_warning)
	stream.logged_error.connect(push_error)
	stream.substream_added.connect(_subscribe)