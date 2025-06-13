@tool
extends RichTextLabel

## Logs a LogStream into a RichTextLabel, in-game or in-editor

const LogStream := preload("uid://kj2lij0iyp3h")

var show_substream_label := true

func _init() -> void:
	bbcode_enabled = true
	scroll_following = true
	subscribe(O2.logger)

func _log(msg: String, stream_name: String = "") -> void:
	if show_substream_label:
		append_text(
			"%s%s\n" % [
				"[%s] " % stream_name if stream_name else "",
				msg
			]
		)
	else:
		append_text(msg + "\n")

func _warn(msg: String, stream_name: String = "") -> void:
	msg = "[color=yellow][i]%s[/i][/color]" % msg
	_log(msg, stream_name)

func _error(msg: String, stream_name: String = "") -> void:
	msg = "[color=red][b]%s[/b][/color]" % msg
	_log(msg, stream_name)

func subscribe(stream: LogStream) -> void:
	if !stream.logged_debug.is_connected(_log):
		stream.logged_debug.connect(_log.bind(stream.name))
	if !stream.logged_info.is_connected(_log):
		stream.logged_info.connect(_log.bind(stream.name))
	if !stream.logged_warn.is_connected(_warn):
		stream.logged_warn.connect(_warn.bind(stream.name))
	if !stream.logged_error.is_connected(_error):
		stream.logged_error.connect(_error.bind(stream.name))
	if !stream.substream_added.is_connected(subscribe):
		stream.substream_added.connect(subscribe)

func unsubscribe(stream: LogStream) -> void:
	stream.logged_debug.disconnect(_log)
	stream.logged_info.disconnect(_log)
	stream.logged_warn.disconnect(_warn)
	stream.logged_error.disconnect(_error)
	stream.substream_added.disconnect(subscribe)