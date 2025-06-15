@tool
extends TabContainer

const LogStream := preload("uid://kj2lij0iyp3h")
const LogToRichTextLabel := preload("uid://dilegsxybdkeg")

var main_handler : LogToRichTextLabel
var substream_handlers : Dictionary[String, LogToRichTextLabel]

func _ready() -> void:
	# TODO can remove when not testing anymore
	for child in get_children():
		remove_child(child)
		child.queue_free()
	main_handler = LogToRichTextLabel.new()
	main_handler.name = "Primary"
	add_child(main_handler, true)
	subscribe(O2.logger)

func subscribe(stream: LogStream) -> void:
	if stream.name:
		var handler : LogToRichTextLabel
		if stream.name in substream_handlers:
			handler = substream_handlers[stream.name]
			handler.subscribe(stream)
		else:
			handler = LogToRichTextLabel.new()
			handler.subscribe(stream)
			substream_handlers[stream.name] = handler
			handler.name = stream.name
			handler.show_substream_label = false
			add_child(handler, true)
	main_handler.subscribe(stream)
	for s in stream.substreams:
		subscribe(stream.substreams[s])
	stream.substream_added.connect(subscribe)

func unsubscribe(stream: LogStream) -> void:
	if stream.name in substream_handlers:
		substream_handlers[stream.name].queue_free()
	stream.substream_added.disconnect(subscribe)
	for s in stream.substreams:
		unsubscribe(stream.substreams[s])