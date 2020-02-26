local mod = get_mod("Hide UI")

return {
	name = "Hide UI",
	description = mod:localize("mod_description"),
	is_togglable = false,

options = {
		widgets  = {	
			{
				setting_id = "hud_toggle_option",
				type="dropdown",
				default_value = "partial",
				options = {
					{text = "option_one_localization_id",   value = "partial"},
					{text = "option_two_localization_id",   value = "total"},
					{text = "option_three_localization_id", value = "plus"}
				},
			},
			{
				setting_id = "UI_toggle_keybind",
				type="keybind",
				default_value={},
				keybind_global=false,
				keybind_trigger="pressed",
				keybind_type="function_call",
				function_name="toggle_UI",				
			},		
		}
	}
}
