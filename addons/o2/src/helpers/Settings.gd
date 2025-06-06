## Gets a setting's current value, or sets it to the initial value and returns that
## Useful so a plugin doesn't need to care if its just initializing its settings or not.
func get_or_add(setting : String, default_value : Variant) -> Variant:
	if not ProjectSettings.has_setting(setting):
		ProjectSettings.set_setting(setting, default_value)
		if default_value != null:
			ProjectSettings.set_initial_value(setting, default_value)
	return ProjectSettings.get_setting(setting)

func _init() -> void: assert(false, "Class can't be instantiated")