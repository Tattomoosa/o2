@tool
class_name ConditionalResource
extends BoolResource

const _Signals := H.Signals

enum Condition {
	IS_TRUE,
	IS_FALSE,
	OR,
	AND,
	EQUAL,
	NOT_EQUAL,
	LESS,
	GREATER,
	LESS_OR_EQUAL,
	GREATER_OR_EQUAL
}

@export var resource_a : VariantResource:
	set(v):
		_Signals.swap(resource_a, v, "value_changed", _check_conditional)
		resource_a = v
		_check_conditional()
@export var condition : Condition:
	set(v):
		condition = v
		_check_conditional()
@export var resource_b : VariantResource:
	set(v):
		_Signals.swap(resource_b, v, "value_changed", _check_conditional)
		resource_b = v
		_check_conditional()

func _init() -> void:
	super()
	_check_conditional()

func _check_conditional() -> void:
	if resource_a:
		if !resource_b:
			if (condition in [Condition.IS_TRUE, Condition.IS_FALSE]):
				resource_name = "if %s %s" % [
					_get_resource_label(resource_a),
					_get_conditional_label(),
				]
			else:
				resource_name = "if %s %s %s" % [
					_get_resource_label(resource_a),
					_get_conditional_label(),
					"<null>"
				]
			match condition:
				Condition.IS_TRUE:
					value = resource_a.value and true
				Condition.IS_FALSE:
					value = !(resource_a.value and true)
				Condition.OR:
					value = resource_a.value or false
				_:
					value = false
		else:
			resource_name = "if %s %s %s" % [
				_get_resource_label(resource_a),
				_get_conditional_label(),
				_get_resource_label(resource_b)
			]
			match condition:
				Condition.OR:
					value = resource_a.value or resource_b.value
				Condition.AND:
					value = resource_a.value and resource_b.value
				Condition.EQUAL:
					value = resource_a.value == resource_b.value
				Condition.NOT_EQUAL:
					value = resource_a.value != resource_b.value
				Condition.LESS:
					value = resource_a.value < resource_b.value
				Condition.GREATER:
					value = resource_a.value > resource_b.value
				Condition.LESS_OR_EQUAL:
					value = resource_a.value <= resource_b.value
				Condition.GREATER_OR_EQUAL:
					value = resource_a.value >= resource_b.value
	else:
		resource_name = "if false"
		value = false
	notify_property_list_changed()
	emit_changed()

func _get_resource_label(resource: VariantResource) -> String:
	return '{%s}' % resource.resource_name if resource.resource_name else str(resource.value)

func _get_conditional_label() -> String:
	match condition:
		Condition.IS_TRUE:
			return "is TRUE"
		Condition.IS_FALSE:
			return "is FALSE"
		Condition.OR:
			return "or"
		Condition.AND:
			return "and"
		Condition.EQUAL:
			return "=="
		Condition.LESS:
			return "<"
		Condition.GREATER:
			return ">"
		Condition.LESS_OR_EQUAL:
			return "<="
		Condition.GREATER_OR_EQUAL:
			return ">="
	return "?"

# Ignore overrides
func set_override_property_info(_property_info: Dictionary) -> void:
	return

func _validate_property(property: Dictionary) -> void:
	if property.name == "value":
		property.usage |= PROPERTY_USAGE_READ_ONLY
	if property.name == "resource_b":
		if condition in [Condition.IS_TRUE, Condition.IS_FALSE]:
			property.usage = PROPERTY_USAGE_NO_EDITOR
	super(property)
