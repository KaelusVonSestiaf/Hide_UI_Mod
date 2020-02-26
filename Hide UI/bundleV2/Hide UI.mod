return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`Hide UI` mod must be lower than Vermintide Mod Framework in your launcher's load order.")

		new_mod("Hide UI", {
			mod_script       = "scripts/mods/Hide UI/Hide UI",
			mod_data         = "scripts/mods/Hide UI/Hide UI_data",
			mod_localization = "scripts/mods/Hide UI/Hide UI_localization",
		})
	end,
	packages = {
		"resource_packages/Hide UI/Hide UI",
	},
}
