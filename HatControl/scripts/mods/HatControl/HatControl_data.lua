local mod = get_mod("HatControl")

return {
	name = "Hat Control",
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets  = {
			{
				setting_id    = "show_window",
				type          = "checkbox",
				default_value = false,
				title = "show_window_localization_id",
				tooltip = "show_window_tooltip_localization_id",
			},	
			{
				setting_id = "toggle_window_keybind",
				type="keybind",
				default_value={},
				keybind_global=false,
				keybind_trigger="pressed",
				keybind_type="function_call",
				function_name="toggle_show_window_variable",				
			},		
		}
	}
}