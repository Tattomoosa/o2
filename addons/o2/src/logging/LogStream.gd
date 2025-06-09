extends Logger

## LogStreams have a 

const Self := preload("LogStream.gd")

signal logged_debug(msg: String)
signal logged_info(msg: String)
signal logged_warn(msg: String)
signal logged_error(msg: String)
signal substream_added(stream: Self)

## Logs less than the LogLevel will not be logged by the stream
enum LogLevel { DEBUG, INFO, WARN, ERROR }

var name := ""
var level := LogLevel.INFO
var substreams : Dictionary[String, Self]

func _init() -> void:
	pass

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		pass
	
func _log_error(function: String, file: String, line: int, code: String, rationale: String, _editor_notify: bool, error_type: int, script_backtraces: Array[ScriptBacktrace]) -> void:
	error(":".join([
		function,
		file,
		line,
		code,
		rationale,
		error_string(error_type),
		script_backtraces,
	]))

func _log_message(message: String, is_error: bool) -> void:
	if is_error:
		error(message)
	else:
		info(message)

## Logs at LogLevel.DEBUG
func debug(
	arg0: Variant="", arg1: Variant="", arg2: Variant="", arg3: Variant="", arg4: Variant="", arg5: Variant="", arg6: Variant="", arg7: Variant="", arg8: Variant="", arg9: Variant=""
) -> void:
	if level > LogLevel.DEBUG:
		return
	var msg := "".join([str(arg0), str(arg1), str(arg2), str(arg3), str(arg4), str(arg5), str(arg6), str(arg7), str(arg8), str(arg9)])
	msg = dim(msg)
	logged_debug.emit(msg)

## Logs at LogLevel.INFO
func info(
	arg0: Variant="", arg1: Variant="", arg2: Variant="", arg3: Variant="", arg4: Variant="", arg5: Variant="", arg6: Variant="", arg7: Variant="", arg8: Variant="", arg9: Variant=""
) -> void:
	if level > LogLevel.INFO:
		return
	var msg := "".join([str(arg0), str(arg1), str(arg2), str(arg3), str(arg4), str(arg5), str(arg6), str(arg7), str(arg8), str(arg9)])
	logged_info.emit(msg)

## Logs at LogLevel.WARN
func warn(
	arg0: Variant="", arg1: Variant="", arg2: Variant="", arg3: Variant="", arg4: Variant="", arg5: Variant="", arg6: Variant="", arg7: Variant="", arg8: Variant="", arg9: Variant=""
) -> void:
	if level > LogLevel.WARN:
		return
	var msg := "".join([str(arg0), str(arg1), str(arg2), str(arg3), str(arg4), str(arg5), str(arg6), str(arg7), str(arg8), str(arg9)])
	logged_warn.emit(msg)

## Logs at LogLevel.ERROR
func error(
	arg0: Variant="", arg1: Variant="", arg2: Variant="", arg3: Variant="", arg4: Variant="", arg5: Variant="", arg6: Variant="", arg7: Variant="", arg8: Variant="", arg9: Variant=""
) -> void:
	var msg := "".join([str(arg0), str(arg1), str(arg2), str(arg3), str(arg4), str(arg5), str(arg6), str(arg7), str(arg8), str(arg9)])
	logged_error.emit(msg)

func _label_if_named(msg: String) -> String:
	if name:
		return label(name) + msg
	return msg

func label(p_label: String) -> String:
	return "[ %s ] " % p_label

func rich_label(p_label: String) -> String:
	return "[color=#aaaaaa]%s[/color]" % label(p_label)

func color(
	p_color: Color,
	arg0: Variant="", arg1: Variant="", arg2: Variant="", arg3: Variant="", arg4: Variant="", arg5: Variant="", arg6: Variant="", arg7: Variant="", arg8: Variant="", arg9: Variant=""
) -> String:
	var msg := "".join([str(arg0), str(arg1), str(arg2), str(arg3), str(arg4), str(arg5), str(arg6), str(arg7), str(arg8), str(arg9)])
	return "[color=#%s]%s[/color]" % [p_color.to_html(), msg]

func dim(
	arg0: Variant="", arg1: Variant="", arg2: Variant="", arg3: Variant="", arg4: Variant="", arg5: Variant="", arg6: Variant="", arg7: Variant="", arg8: Variant="", arg9: Variant=""
) -> String:
	var msg := "".join([str(arg0), str(arg1), str(arg2), str(arg3), str(arg4), str(arg5), str(arg6), str(arg7), str(arg8), str(arg9)])
	return color(Color(Color.WHITE, 0.6), msg)

func add_substream(stream_level: LogLevel, stream_name: String) -> Self:
	assert(stream_name, "Anonymous sub-streams are not allowed")
	if stream_name in substreams:
		var old_stream := substreams[stream_name]
		old_stream.logged_debug.disconnect(debug)
		old_stream.logged_info.disconnect(info)
		old_stream.logged_warning.disconnect(warn)
		old_stream.logged_error.disconnect(error)
	var stream := Self.new()
	stream.level = stream_level
	stream.logged_debug.connect(debug)
	stream.logged_info.connect(info)
	stream.logged_warning.connect(warn)
	stream.logged_error.connect(error)
	substreams[stream_name] = stream
	substream_added.emit(stream)
	return stream