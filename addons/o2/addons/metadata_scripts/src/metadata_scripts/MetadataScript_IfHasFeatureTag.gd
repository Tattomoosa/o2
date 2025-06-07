@tool
class_name MetadataScript_IfHasFeatureTag
extends MetadataScript

const FEATURES := "android, bsd, linux, macos, ios, windows, linuxbsd, debug, release, editor, editor_hint, editor_runtime, template, double, single, 64, 32, x86_64, x86_32, x86, arm64, arm32, arm, rv64, riscv, ppc64, ppc32, ppc, wasm64, wasm32, wasm, mobile, pc, web, web_android, web_ios, web_linuxbsd, web_macos, web_windows, etc, etc2, s3tc, movie"

@export_custom(PROPERTY_HINT_ENUM_SUGGESTION, FEATURES) var feature : String
@export var invert : bool

func _enter_tree() -> void:
	if Engine.is_editor_hint():
		return
	if OS.has_feature(feature):
		if invert: node.queue_free()
	else:
		if !invert: node.queue_free()