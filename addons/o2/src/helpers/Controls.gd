## Uses CSS rules
static func margin_container(
	margin0: int,
	margin1 := margin0,
	margin2 := margin0,
	margin3 := margin1,
) -> MarginContainer:
	var mc := MarginContainer.new()
	mc.add_theme_constant_override("margin_top", margin0)
	mc.add_theme_constant_override("margin_right", margin1)
	mc.add_theme_constant_override("margin_bottom", margin2)
	mc.add_theme_constant_override("margin_left", margin3)
	return mc

static func icon_button(icon: Texture2D, flat := false) -> Button:
	var button := Button.new()
	button.icon = icon
	button.flat = flat
	return button

static func icon_menu_button(icon: Texture2D, flat := false) -> MenuButton:
	var button := MenuButton.new()
	button.icon = icon
	button.flat = flat
	return button

static func create_vbox(
	separation: int = 0,
) -> VBoxContainer:
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", separation)
	return vbox

static func create_hbox(
	separation: int = 0,
) -> HBoxContainer:
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", separation)
	return hbox

static func add_children(parent: Control, controls: Array[Control], internal := Node.INTERNAL_MODE_DISABLED) -> void:
	for node in controls:
		if node.get_parent():
			node.get_parent().remove_child(node)
		parent.add_child(node, false, internal)

# ehhh
static func layout(controls: Dictionary) -> Control:
	var parent : Control = controls.control
	var children : Array = controls.children
	for item in children:
		var control : Control = item if item is Control else item.control
		if control.get_parent():
			control.get_parent().remove_child(control)
		if item is Control:
			parent.add_child(item)
		elif item is Dictionary:
			parent.add_child(
				control,
				item.get("force_readable_name", false),
				item.get("internal", Control.INTERNAL_MODE_DISABLED)
			)
			if "expand" in item:
				if item.expand:
					control.size_flags_horizontal = Control.SIZE_EXPAND_FILL
					control.size_flags_vertical = Control.SIZE_EXPAND_FILL
				else:
					control.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
					control.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
			if "position" in item:
				parent.move_child(control, item.position)
			if "children" in item:
				layout(item)
	return parent

## Static class
func _init() -> void: assert(false, "Class can't be instantiated")