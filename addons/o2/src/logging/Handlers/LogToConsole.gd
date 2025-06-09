@tool

const LogStream := preload("uid://kj2lij0iyp3h")

static var _stream : LogStream

static func subscribe(stream: LogStream) -> void:
	_subscribe(stream)
	_stream = stream

static func unsubscribe() -> void:
	_unsubscribe(_stream)
	_stream = null

static func _log(msg: String, stream_name := "") -> void:
	print_rich(
		"%s%s" % [
			"[%s] : " % stream_name if stream_name else "",
			msg
		]
	)

static func _warn(msg: String, stream_name: String = "") -> void:
	push_warning(
		"%s%s" % [
			"[%s] : " % stream_name if stream_name else "",
			msg
		]
	)

static func _error(msg: String, stream_name: String = "") -> void:
	push_warning(
		"%s%s" % [
			"[%s] : " % stream_name if stream_name else "",
			msg
		]
	)

static func _subscribe(stream: LogStream) -> void:
	stream.logged_debug.connect(_log)
	stream.logged_info.connect(_log)
	stream.logged_warn.connect(_warn)
	stream.logged_error.connect(_error)
	stream.substream_added.connect(_subscribe)

static func _unsubscribe(stream: LogStream) -> void:
	stream.logged_debug.disconnect(_log)
	stream.logged_info.disconnect(_log)
	stream.logged_warn.disconnect(_warn)
	stream.logged_error.disconnect(_error)
	stream.substream_added.disconnect(_subscribe)