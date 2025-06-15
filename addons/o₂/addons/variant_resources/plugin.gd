@tool
extends EditorPlugin

const VariantResourceInspector := preload("uid://b6p1blka8mr6p")
const OverridePropertyInspector := preload("uid://dydrtv4vr7wfw")

var inspector_plugin : VariantResourceInspector
var override_inspector_plugin : OverridePropertyInspector

func _enable_plugin() -> void:
	pass

func _disable_plugin() -> void:
	pass

func _enter_tree() -> void:
	inspector_plugin = VariantResourceInspector.new()
	override_inspector_plugin = OverridePropertyInspector.new()
	add_inspector_plugin(inspector_plugin)
	add_inspector_plugin(override_inspector_plugin)

func _exit_tree() -> void:
	remove_inspector_plugin(inspector_plugin)
	remove_inspector_plugin(override_inspector_plugin)
	inspector_plugin = null
	override_inspector_plugin = null
