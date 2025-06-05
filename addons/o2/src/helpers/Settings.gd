func get_or_add(setting : String, default_value : Variant) -> Variant:
	if not ProjectSettings.has_setting(setting):
		ProjectSettings.set_setting(setting, default_value)
		if default_value != null:
			ProjectSettings.set_initial_value(setting, default_value)
	return ProjectSettings.get_setting(setting)

func _init() -> void: assert(false, "Class can't be instantiated")