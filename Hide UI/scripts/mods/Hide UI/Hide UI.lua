local mod = get_mod("Hide UI")

--<LOCAL VARIABLES>--
local manual_realism_is_on --Partial UI toggle (works just as the Act on Instinct (realism) mutator)
local disable_ui --Complete UI toggle
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

local function mod_setup() --Triggers when the mod starts and whenever one of my settings gets changed
	toggle_setting = mod:get("hud_toggle_option")

	--re-enable the UI
	manual_realism_is_on = false
	disable_ui = false

	
	--unhide arms and weapons
	local local_player_unit = Managers.player:local_player().player_unit
	local first_person_extension = ScriptUnit.extension(local_player_unit, "first_person_system")
	first_person_extension:unhide_weapons(first_person_extension, "ui_off")
	Unit.set_unit_visibility(first_person_extension.first_person_attachment_unit, true)
	--Managers.chat:send_chat_message(1, 1, "Hide UI mod properly initialized.")
end

local function can_toggle ()--Can I toggle the UI?
	local input_player = Managers.input:get_service("Player")
	local cant_control = input_player and input_player:is_blocked() --Can the player move?
	
	local local_player_unit = Managers.player:local_player().player_unit
	local input_system_extension = ScriptUnit.extension(local_player_unit, "input_system")
	local is_inspecting = input_system_extension:get("character_inspecting") --Is the player inspecting his character?
	return (not (cant_control or is_inspecting))
end


local function toggle_Realism() --Partially turns off the UI (Same functionality as if the Act on Instinct mutator was active)
	if (manual_realism_is_on) then
		manual_realism_is_on = false
		enable_outlines()
		--Managers.chat:send_chat_message(1, 1, "Realism should now be off.")
	else
		manual_realism_is_on = true
		disable_outlines()
		--Managers.chat:send_chat_message(1, 1, "Realism should now be on.")
	end
end

local function toggle_UI_complete() --Completely turns off the UI
	if (disable_ui) then
		disable_ui = false
		enable_outlines()		
		--Managers.chat:send_chat_message(1,1, "UI should now be on.")
	else
		disable_ui = true
		disable_outlines()		
		--Managers.chat:send_chat_message(1,1, "UI should now be off.")
	end
end

local function toggle_UI_plus() --Turns off the first person arms and weapons, and then calls toggle_UI_complete
	local local_player_unit = Managers.player:local_player().player_unit
	local first_person_extension = ScriptUnit.extension(local_player_unit, "first_person_system")
	if (disable_ui) then
		first_person_extension:unhide_weapons(first_person_extension, "ui_off")
		Unit.set_unit_visibility(first_person_extension.first_person_attachment_unit, true)
		--Managers.chat:send_chat_message(1,1, "UI and arms should now be on.")
	else
		first_person_extension:hide_weapons(first_person_extension, "ui_off", true)
		Unit.set_unit_visibility(first_person_extension.first_person_attachment_unit, false)
		--Managers.chat:send_chat_message(1,1, "UI and arms should now be off.")
	end
	toggle_UI_complete()
end


--<PUBLIC FUNCTIONS AND HOOKS>--
function mod.toggle_UI() --Toggles the UI according to the "hud_toggle_option" setting
	if can_toggle() then
		if (toggle_setting == "partial") then 
			toggle_Realism()
		elseif (toggle_setting == "total") then
			toggle_UI_complete()
		else toggle_UI_plus()
		end
	--else Managers.chat:send_chat_message(1,1, "Control is blocked, or you are inspecting character!")
	end
end



---realism_mutator defined in line 9
mod:hook(realism_mutator, "client_stop_function", function (func, context, data) --Prevents the end of the Act on Instinct mutator from re-enabling the outline system, if the player has turned off the ui with my mod.
	if (not (manual_realism_is_on or disable_ui)) then 
		return func(context,data) 
	end
end)


---realism_group defined in line 7
mod:hook(realism_group, "validation_function", function (func, ingame_hud) --Hooks my mod into the visibility group 'realism', so that the visibility group is active whether my mod activates it, or the game does.
	local result = func(ingame_hud)
	return (manual_realism_is_on or result)
end)
	

---disable_ingame_ui_group defined in line 8
mod:hook(disable_ingame_ui_group, "validation_function", function (func, ingame_hud) --Hooks my mod into the visibility group 'disable ingame ui', so that the visibility group is active whether my mod activates it, or the game does.
	local result = func(ingame_hud)
	return (disable_ui or result)
end)


mod:hook(TwitchIconView, "_draw", function(func, self, ...) --Hide the Twitch mode icon in lower right.
	if (disable_ui or manual_realism_is_on) then
		return
	end
	return func(self, ...)
end)


mod:hook_safe(PlayerUnitFirstPerson, "set_first_person_mode", function (self, active, override)--Re-hides the first person arms if something turns them on when I don't want to (like exiting inspect state) (fuck you, inspect state)
	if (active and toggle_setting=="plus" and disable_ui) then
		Unit.set_unit_visibility(self.first_person_attachment_unit,false)
	end
end)


mod.on_setting_changed = function(setting_name) --Reset mod when a mod setting is changed
	mod_setup()
	enable_outlines()
	return
end
--mod starts
mod_setup()