ammo_type = ammo_type or function(info)
    LS_lua_run("lua/addons/ammo_type.lua", info)
end

call_ammo_menu = call_ammo_menu or function()
    openMenu(myAmmoMenu)
end

back_to_main_options = back_to_main_options or function()
    openMenu(myMenu)
end

ammo_options = ammo_options or 
{
    {},
    { text = "000 Buckshot", callback = function() ammo_type(1) end },
    { text = "HE Round", callback = function() ammo_type(2) end },
    { text = "AP Slug", callback = function() ammo_type(3) end },
    {},
    { text = "Back", callback = back_to_main_options },
    { text = "Close", is_cancel_button = true, is_focused_button = true },
}

myAmmoMenu = myAmmoMenu or SimpleMenu:new("Loadout Swapper By AntonisK", "Change Ammo Type Options", ammo_options)
