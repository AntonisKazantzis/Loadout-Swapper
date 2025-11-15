local LS = _G.LoadoutSwapper or {}
local LS_require = _G.LS_require
local LS_lua_run = _G.LS_lua_run

LS_require("lua/tools/simple_menu")
LS_require("lua/tools/log_error")
LS_require("lua/tools/tools")
LS_require("lua/menu/weapon_menu")
LS_require("lua/menu/gear_menu")
LS_require("lua/menu/ammo_menu")

function openMenu(menu)
    menu:show()
end

options = options or 
{
	{},
	{ text = "Change Weapon Loadout", callback = function() call_weapon_menu() end }, 
	{ text = "Change Gear Loadout", callback = function() call_gear_menu() end },
	{ text = "Ammo Type", callback = function() call_ammo_menu() end },
	{},
	{ text = "Close", is_cancel_button = true, is_focused_button = true }
}

if LS:inSteelsight() or LS:inCustody() or LS:inChat() or LS:inTitlescreen() then return end

LS:storeAllLoadout()
-- LS:logEquipmentSelections()

local message = ""

if LS:inGame() then
	message = "In Game Main Options"
elseif LS:inBriefing() then
    message = "In Briefing Main Options"
elseif LS:inLobby() then
    message = "In Lobby Main Options"
end

if not myMenu then
    myMenu = myMenu or SimpleMenu:new("Loadout Swapper By AntonisK", message, options)
end

myMenu:show()