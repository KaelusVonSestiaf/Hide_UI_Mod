local mod = get_mod("Hide UI")

--<LOCAL VARIABLES>--
local disable_ui
local toggle_setting
local realism_group = require("scripts/ui/views/ingame_hud_definitions").visibility_groups_lookup.realism
local disable_ingame_ui_group = require("scripts/ui/views/ingame_hud_definitions").visibility_groups_lookup.disable_ingame_ui
local realism_mutator = require("scripts/settings/mutators/mutator_realism")


--<LOCAL FUNCTIONS>--
local function disable_outlines() --disables the outline system
	local outline_system = Managers.state.entity:system("outline_system")
	outline_system:set_disabled(true)
end
local function enable_outlines() --enables the outline system
	if (not Managers.state.game_mode:has_activated_mutator("realism")) then --but only if the Act on Instinct mutator isn't active
		local outline_system = Managers.state.entity:system("outline_system")
		outline_system:set_disabled(false)
	end
end

local function mod_setup() --Triggers when the mod starts and whenever the hood_toggle_option setting gets changed
	toggle_setting = mod:get("hud_toggle_option")
	disable_ui = false
	
	--Toggle the appropiate hooks
	if (toggle_setting=="partial") then
		mod:hook_enable(realism_group, "validation_function")
		mod:hook_disable(disable_ingame_ui_group, "validation_function")
		mod:hook_disable(PlayerUnitFirstPerson, "set_first_person_mode")
	elseif (toggle_setting=="total") then
		mod:hook_disable(realism_group, "validation_function")
		mod:hook_enable(disable_ingame_ui_group, "validation_function")
		mod:hook_disable(PlayerUnitFirstPerson, "set_first_person_mode")
	else
		mod:hook_disable(realism_group, "validation_function")
		mod:hook_enable(disable_ingame_ui_group, "validation_function")
		mod:hook_enable(PlayerUnitFirstPerson, "set_first_person_mode")
	end	
end

local function can_toggle ()--Can I toggle the UI?
	local input_player = Managers.input:get_service("Player")
	local cant_control = input_player and input_player:is_blocked() --Can the player move?
	--if (cant_control) then mod:echo("Control is blocked!") end
	return (not (cant_control))
end


local function turn_on_arms()
	local local_player_unit = Managers.player:local_player().player_unit
	if Unit.alive(local_player_unit) then
		local first_person_extension = ScriptUnit.extension(local_player_unit, "first_person_system")
		first_person_extension:unhide_weapons(first_person_extension, "ui_off")
		if (first_person_extension.first_person_mode) then
			first_person_extension:unhide_weapons(first_person_extension, "ui_off")
			Unit.set_unit_visibility(first_person_extension.first_person_attachment_unit, true)		
		--else mod:echo("Can't turn on arms, not in first person!")
		end
	--else mod:echo("Can't turn on arms, you don't exist!")
	end
end

local function turn_off_arms()
	local local_player_unit = Managers.player:local_player().player_unit
	if Unit.alive(local_player_unit) then
		local first_person_extension = ScriptUnit.extension(local_player_unit, "first_person_system")
		first_person_extension:hide_weapons(first_person_extension, "ui_off", true)
		Unit.set_unit_visibility(first_person_extension.first_person_attachment_unit, false)
	end
end

--<PUBLIC FUNCTIONS>--
function mod.toggle_UI() --Toggles the UI according to the "hud_toggle_option" setting
	if can_toggle() then
		if (disable_ui) then
			disable_ui = false
			enable_outlines()
			if (toggle_setting=="plus") then turn_on_arms() end
			--mod:echo("UI should now be on.")
		else
			disable_ui = true
			disable_outlines()
			if (toggle_setting=="plus") then turn_off_arms() end
			--Managers.chat:send_chat_message(1,1, "UI should now be off.")
		end
	--else mod:echo("Control is blocked!")
	end
end

mod.on_setting_changed = function(setting_name) --Reset mod when the toggle mode is changed
	if (setting_name == "hud_toggle_option") then
		mod_setup()
		enable_outlines()
		turn_on_arms()
	end
end


--<HOOKS THAT HAVE TO ALWAYS BE ON>--
mod:hook(TwitchIconView, "_draw", function(func, self, ...) --Hide the Twitch mode icon in lower right.
	if (disable_ui) then
		return
	end
	return func(self, ...)
end)

---realism_mutator defined in line 9
mod:hook(realism_mutator, "client_stop_function", function (func, context, data) --Prevents the end of the Act on Instinct mutator from re-enabling the outline system, if the player has turned off the ui with my mod.
	if (not (disable_ui)) then 
		return func(context,data) 
	end
end)


--<HOOKS THAT I SHOULD ENABLE/DISABLE AS NEEDED>--

---realism_group defined in line 7
mod:hook(realism_group, "validation_function", function (func, ingame_hud) --Hooks my mod into the visibility group 'realism', so that the visibility group is active whether my mod activates it, or the game does.
	local result = func(ingame_hud)
	return (disable_ui or result)
end)
	

---disable_ingame_ui_group defined in line 8
mod:hook(disable_ingame_ui_group, "validation_function", function (func, ingame_hud) --Hooks my mod into the visibility group 'disable ingame ui', so that the visibility group is active whether my mod activates it, or the game does.
	local result = func(ingame_hud)
	return (disable_ui or result)
end)


mod:hook_safe(PlayerUnitFirstPerson, "set_first_person_mode", function (self, active, override)--Re-hides the first person arms if something turns them on when I don't want to
	if (active) then
		camera_moving_to_first_person = false
		if (toggle_setting=="plus" and disable_ui) then
			Unit.set_unit_visibility(self.first_person_attachment_unit,false)
		end
	end
end)



--mod starts
mod_setup()