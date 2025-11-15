_G.LoadoutSwapper = _G.LoadoutSwapper or {}
_G.LS_SELECTED_WEAPON = tostring(info)

local LoadoutSwapper = _G.LoadoutSwapper or {}
local LS = _G.LoadoutSwapper or {}

back_to_weapon_options = back_to_weapon_options or function() openMenu(myWeaponMenu) end

function LoadoutSwapper:equipWeapon(category, slot)
    local primary = category == "primaries"
	local first_time = true

	local function clbk()
		if first_time then
			managers.blackmarket:equip_weapon(category, slot)

			first_time = false
		end

		if not managers.network:session():local_peer():is_outfit_loaded() then
			return false
		end

		local weapon = Global.blackmarket_manager.crafted_items[category][slot]
		local texture_switches = managers.blackmarket:get_weapon_texture_switches(category, slot, weapon)

		managers.player:player_unit():inventory():add_unit_by_factory_name(weapon.factory_id, true, false, weapon.blueprint, weapon.cosmetics, texture_switches)

		return true
	end

	local weapon = Global.blackmarket_manager.crafted_items[category][slot]
	local factory_id = weapon.factory_id
	local blueprint = weapon.blueprint
	local ids_unit_name = Idstring(managers.weapon_factory:get_weapon_unit(factory_id, blueprint))

	if not managers.dyn_resource:is_resource_ready(Idstring("unit"), ids_unit_name, managers.dyn_resource.DYN_RESOURCES_PACKAGE) then
		managers.dyn_resource:load(Idstring("unit"), ids_unit_name, managers.dyn_resource.DYN_RESOURCES_PACKAGE, nil)
	end

	managers.player:player_unit():movement():current_state():_start_action_unequip_weapon(TimerManager:game():time(), {
		selection_wanted = primary and 2 or 1,
		unequip_callback = clbk
	})
end

-- Show stored weapons
function LoadoutSwapper:openWeaponCategoryMenu()
    self:load()

    local menu_options = {}
    local selected_weapon = _G.LS_SELECTED_WEAPON
    local weapon_data = self.data[selected_weapon]
    local title = "Loadout Swapper By AntonisK"
    local message = "Weapon Loadout Options"

    if not weapon_data or not weapon_data.available_slots or #weapon_data.available_slots == 0 then
        table.insert(menu_options, {})
        table.insert(menu_options, {text = "No Weapons Found", callback = back_to_weapon_options})
    else
        message = "Weapon Loadout Options For " .. self:ucfirst(selected_weapon)

        for i, weapon in ipairs(weapon_data.available_slots) do
            local LS = _G.LoadoutSwapper or {}
            local name = weapon.name or weapon.id -- fallback

            self:switch(selected_weapon, {
                ["primaries"] = 
                    function()
                        table.insert(menu_options, {
                            text = name,
                            callback = function() LS:equipWeapon(selected_weapon, weapon.slot) end
                        })
                    end,
                ["secondaries"] = 
                    function()
                        table.insert(menu_options, {
                            text = name,
                            callback = function() LS:equipWeapon(selected_weapon, weapon.slot) end
                        })
                    end,
                ["melees"] = 
                function()
                    table.insert(menu_options, {
                        text = name,
                        callback = function() managers.blackmarket:equip_melee_weapon(weapon.id) end
                    })
                end,
                ["default"] = function() self:scriptLog("[LoadoutSwapper]: Something Went Wrong...", Color.red) end
            })
        end
    end

    table.insert(menu_options, {})
    table.insert(menu_options, {text = "Back", callback = back_to_weapon_options})
    table.insert(menu_options, {text = "Close", is_cancel_button = true, is_focused_button = true})

    local myWeaponMenu = SimpleMenu:new(title, message, menu_options, 10)
    myWeaponMenu:show()
end

-- Helper: Open the correct menu
function LoadoutSwapper:openWeaponMenu()
    local selected_weapon = _G.LS_SELECTED_WEAPON

    if not selected_weapon then return self:scriptLog("[LoadoutSwapper]: Something Went Wrong...", Color.red) end

    if self:inLobby() then
        self:switch(selected_weapon, {
            ["primaries"] = function() PlayerInventoryGui:open_primary_menu() end,
            ["secondaries"] = function() PlayerInventoryGui:open_secondary_menu() end,
            ["melees"] = function() PlayerInventoryGui:open_melee_menu() end,
            ["default"] = function() self:scriptLog("[LoadoutSwapper]: Something Went Wrong...", Color.red) end
        })
    elseif self:inBriefing() then
        if not NewLoadoutTab then return end
        
        if not NewLoadoutTab._my_menu_component_data then NewLoadoutTab._my_menu_component_data = {} end

        self:switch(selected_weapon, {
            ["primaries"] = function()
                NewLoadoutTab._my_menu_component_data.changing_loadout = "primaries"
                NewLoadoutTab._my_menu_component_data.current_slot = managers.blackmarket:equipped_weapon_slot("primaries")
                NewLoadoutTab:open_node(1)
            end,
            ["secondaries"] = function() 
                NewLoadoutTab._my_menu_component_data.changing_loadout = "secondaries"
                NewLoadoutTab._my_menu_component_data.current_slot = managers.blackmarket:equipped_weapon_slot("secondaries")
                NewLoadoutTab:open_node(2)
            end,
            ["melees"] = function() 
                NewLoadoutTab:open_node(3)
            end,
            ["default"] = function() self:scriptLog("[LoadoutSwapper]: Something Went Wrong...", Color.red) end
        })
    elseif self:inGame() and self:getPlayer() then
        self:openWeaponCategoryMenu()
    else
        self:scriptLog("[LoadoutSwapper]: Something Went Wrong...", Color.red)
    end
end

LS:load()
LS:openWeaponMenu()