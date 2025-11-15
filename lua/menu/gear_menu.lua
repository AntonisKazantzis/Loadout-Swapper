gear_loadout = gear_loadout or function(info)
    LS_lua_run("lua/addons/gear_loadout.lua", info)
end

call_gear_menu = call_gear_menu or function()
    openMenu(myGearMenu)
end

back_to_main_options = back_to_main_options or function()
    openMenu(myMenu)
end

gear_options = gear_options or {
    {},
    { text = "Throwable", callback = function() gear_loadout(4) end },
    { text = "Armor", callback = function() gear_loadout(5) end },
    { text = "Equipment", callback = function() gear_loadout(6) end },
    {},
    { text = "Back", callback = back_to_main_options },
    { text = "Close", is_cancel_button = true, is_focused_button = true },
}

myGearMenu = myGearMenu or SimpleMenu:new("Loadout Swapper By AntonisK", "Change Gear Loadout Options", gear_options)
