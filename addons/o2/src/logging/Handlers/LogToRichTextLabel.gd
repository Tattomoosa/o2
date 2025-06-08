@tool
extends RichTextLabel

## Logs a LogStream into a RichTextLabel, in-game or in-editor

const LogStream := preload("uid://kj2lij0iyp3h")

func _init() -> void:
	bbcode_enabled = true
	scroll_following = true
	_subscribe(o2.Log)

func _log(msg: String, stream_name: String = "") -> void:
	append_text(
		"%s%s\n" % [
			"[%s] : " % stream_name if stream_name else "",
			msg
		]
	)

func _warn(msg: String, stream_name: String = "") -> void:
	msg = "[color=yellow][i]%s[/i][/color]" % msg
	_log(msg, stream_name)

func _error(msg: String, stream_name: String = "") -> void:
	msg = "[color=red][b]%s[/b][/color]" % msg
	_log(msg, stream_name)

func _subscribe(p_stream: LogStream) -> void:
	p_stream.logged_debug.connect(_log.bind(p_stream.name))
	p_stream.logged_info.connect(_log.bind(p_stream.name))
	p_stream.logged_warn.connect(_warn.bind(p_stream.name))
	p_stream.logged_error.connect(_error.bind(p_stream.name))
	p_stream.substream_added.connect(_subscribe)