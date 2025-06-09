@tool

const LogStream := preload("uid://kj2lij0iyp3h")

static var _stream : LogStream

static func subscribe(stream: LogStream) -> void:
	_subscribe(stream)
	_stream = stream

static func unsubscribe() -> void:
	_unsubscribe(_stream)
	_stream = null

static func _subscribe(stream: LogStream) -> void:
	if _stream:
		_unsubscribe(_stream)
	stream.logged_debug.connect(print_rich)
	stream.logged_info.connect(print_rich)
	stream.logged_warn.connect(push_warning)
	stream.logged_error.connect(push_error)
	# stream.substream_added.connect(_subscribe)

static func _unsubscribe(stream: LogStream) -> void:
	stream.logged_debug.disconnect(print_rich)
	stream.logged_info.disconnect(print_rich)
	stream.logged_warn.disconnect(push_warning)
	stream.logged_error.disconnect(push_error)
	# stream.substream_added.disconnect(_subscribe)