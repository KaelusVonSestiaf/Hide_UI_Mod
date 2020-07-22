return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`HatControl` mod must be lower than Vermintide Mod Framework in your launcher's load order.")

		new_mod("HatControl", {
			mod_script       = "scripts/mods/HatControl/HatControl",
			mod_data         = "scripts/mods/HatControl/HatControl_data",
			mod_localization = "scripts/mods/HatControl/HatControl_localization",
		})
	end,
	packages = {
		"resource_packages/HatControl/HatControl",
	},
}
