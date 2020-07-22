local mod = get_mod("HatControl")


local show_window = mod:get("show_window")
local template_default_event_table = {} --this is a table that the mod will fill with the default show_attachments_event for each template
local attachment_events_table = {} --this is a table that holds what show_attachments_events belong to each character, used to display only the necessary buttons
attachment_events_table.witch_hunter = {
	"lua_show_ears",
	"lua_hide_ears",
	"lua_mask"
}
attachment_events_table.wood_elf = {
	"lua_head_default",
	"lua_half_mask",
	"lua_mask",
	"lua_head_default_no_face",
	"lua_helmet",
	"lua_helmet_mask",
	"lua_show_ears"
}
attachment_events_table.empire_soldier = {
	"lua_hide_ears",
	"lua_hide_ears_moustache",
	"lua_hide_ears_nose_moustache",
	"lua_hide_ears_beard",
	"lua_hide_beard",
	"lua_show_ears",
	"lua_show_beard",
	}
attachment_events_table.dwarf_ranger = {
	"lua_show_ears",
	"lua_hide_ears",
	"lua_hide_beard_ears",
	"lua_normal_nose",
	"lua_big_nose"
}
attachment_events_table.bright_wizard = {
	"lua_show_ears",
	"lua_hide_hair",
	"lua_hide_ears",
	"lua_hide_ears_hair"
}


mod.on_setting_changed = function(setting_name) 
	show_window = mod:get("show_window")
end

function mod.toggle_show_window_variable()
    show_window = (not (show_window))
    mod:set("show_window", show_window, false)
end

local function get_character() --returns the name of the current character the player is using
    local player_manager = Managers.player
	local player = player_manager:local_player()
	local profile_index = player:profile_index()
    local profile = SPProfiles[profile_index]
    if profile then
        return profile.display_name --witch_hunter // wood_elf // empire_soldier // dwarf_ranger // bright_wizard
    end
end

local function get_current_hat_template() --returns the item_template of the currently worn hat, or nil
	local local_player_unit = Managers.player:local_player().player_unit
	local attachment_extension = ScriptUnit.has_extension(local_player_unit, "attachment_system")
	local item_template
	if attachment_extension then
		local hat_slot_data = attachment_extension._attachments.slots["slot_hat"]
		if (hat_slot_data) then --could be in the middle of changing hats
			local hat_data = hat_slot_data.item_data
			item_template = BackendUtils.get_item_template(hat_data)
		end
	end
	return item_template
end

local function get_current_hat_template_name() --returns the name of the current hat template
	local template = get_current_hat_template()
	if template then --could be in the middle of changing hats
		local name = template.name
		return name
	end
end

local function get_current_attachment_event() --returns the show_attachments_event of the current hat
	local item_template = get_current_hat_template()
	if item_template then
		return item_template.show_attachments_event
	else
		return "No hat found."
	end
end

function mod.update()
	if show_window then
		Imgui.begin_window("Hat Control")
			for key, event in pairs(attachment_events_table[get_character()]) do
				local current_template_name = get_current_hat_template_name()
				local current_attachment_event = get_current_attachment_event()

				if ((not template_default_event_table[current_template_name]) and (current_template_name)) then --saves the default show_attachments_event per template
					template_default_event_table[current_template_name] = current_attachment_event
				end

				local button_name = event
				if (template_default_event_table[current_template_name] == event) then --adds [DEFAULT] to the button of the template's default show_attachments_event
					button_name = button_name .. " [DEFAULT]"
				end
				if (current_attachment_event == event) then --makes the button of the current show_attachments_event you're using green
					Imgui.push_style_color(21, 50, 200, 50, 200)
				end
				if Imgui.button(button_name) then --adds the button
					Unit.flow_event(Managers.player:local_player().player_unit, event)
					local item_template = get_current_hat_template()
					item_template.show_attachments_event = event
				end
				if (current_attachment_event == event) then --have to pop the color to make sure it only affects the button
					Imgui.pop_style_color(1)
				end
				
			end
		Imgui.end_window()
	end
end