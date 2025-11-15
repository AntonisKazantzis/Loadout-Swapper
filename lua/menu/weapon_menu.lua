weapon_loadout = weapon_loadout or function(info)
    LS_lua_run("lua/addons/weapon_loadout.lua", info)
end

call_weapon_menu = call_weapon_menu or function()
    openMenu(myWeaponMenu)
end

back_to_main_options = back_to_main_options or function()
    openMenu(myMenu)
end

weapon_options = weapon_options or 
	{
		{},
		{ text = "Primary Weapons", callback = function() weapon_loadout("primaries") end },
		{ text = "Secondary Weapons", callback = function() weapon_loadout("secondaries") end },
		{ text = "Melee Weapons", callback = function() weapon_loadout("melees") end },
		{},
		{ text = "Back", callback = back_to_main_options},
		{ text = "Close", is_cancel_button = true, is_focused_button = true },
	}
myWeaponMenu = myWeaponMenu or SimpleMenu:new("Loadout Swapper By AntonisK", "Change Weapon Loadout Options", weapon_options)