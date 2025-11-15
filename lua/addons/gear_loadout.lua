_G.LoadoutSwapper = _G.LoadoutSwapper or {}
_G.LS_SELECTED_GEAR = tonumber(info)

local LoadoutSwapper = _G.LoadoutSwapper or {}
local LS = _G.LoadoutSwapper or {}

back_to_gear_options = back_to_gear_options or function() openMenu(myGearMenu) end

function LoadoutSwapper:clearEquipment(target_slot)
    local selections = managers.player._equipment.selections
    local equipped_primary = managers.blackmarket:equipped_deployable(1)
    local equipped_secondary = managers.blackmarket:equipped_deployable(2)

    -- Iterate backwards to safely remove
    for i = #selections, 1, -1 do
        local sel_equipment = selections[i]
        if sel_equipment and sel_equipment.equipment then
            local keep_equipment = (sel_equipment.equipment == equipped_primary and 1 ~= target_slot) or (sel_equipment.equipment == equipped_secondary and 2 ~= target_slot)

            if not keep_equipment then
                -- Remove the equipment properly
                managers.player:remove_equipment(sel_equipment.equipment, target_slot)

                -- Remove from selections to prevent duplicates
                table.remove(selections, i)
            end
        end
    end

    -- Clear the BlackMarketManager slot for this target
    managers.blackmarket:equip_deployable({
        name = nil,
        target_slot = target_slot
    })

    -- Safely adjust selected_index
    if managers.player._equipment.selected_index > #selections then
        managers.player._equipment.selected_index = #selections
    end

    return true
end
		
function LoadoutSwapper:equipEquipment(target_equipment_id)
	local target_equipment_slot = self:getSlot()
    self:clearEquipment(target_equipment_slot)

    local params = {silent = true, equipment = target_equipment_id, slot = target_equipment_slot}

    local equipment = params.equipment
    local tweak_data = tweak_data.equipments[equipment]
    local amount = {}
    local amount_digest = {}
    local quantity = tweak_data.quantity

    for i = 1, #quantity do
        local equipment_name = equipment
        if tweak_data.upgrade_name then
            equipment_name = tweak_data.upgrade_name[i]
        end
        local amt = (quantity[i] or 0) + managers.player:equiptment_upgrade_value(equipment_name, "quantity")
        amt = managers.modifiers:modify_value("PlayerManager:GetEquipmentMaxAmount", amt, params)
        table.insert(amount, amt)
        table.insert(amount_digest, Application:digest_value(0, true))
    end

	local icon = params.icon or tweak_data and tweak_data.icon
	local use_function_name = params.use_function_name or tweak_data and tweak_data.use_function_name
	local use_function = use_function_name or nil

    if params.slot and params.slot > 1 then
        for i = 1, #quantity do amount[i] = math.ceil(amount[i] / 2) end
    end

    table.insert(managers.player._equipment.selections, 1, {
		equipment = equipment,
		amount = amount_digest,
		use_function = use_function,
		action_timer = tweak_data.action_timer,
		icon = icon,
		unit = tweak_data.unit,
		on_use_callback = tweak_data.on_use_callback
	})
    
	self:addHudItem(amount, icon)

    managers.player:set_equipment_in_slot(target_equipment_id, target_equipment_slot)

    for i = 1, #amount do
        managers.player:add_equipment_amount(equipment, amount[i], i)
        managers.player:update_deployable_equipment_amount_to_peers(equipment, amount[i])
    end

    if managers.menu_scene then
        managers.menu_scene:set_character_deployable(equipment, false, 0)
    end

    MenuCallbackHandler:_update_outfit_information()
    if SystemInfo:distribution() == Idstring("STEAM") then
        managers.statistics:publish_equipped_to_steam()
    end
end

function LoadoutSwapper:equipGrenade(target_grenade_id, target_grenade_amount)
	local peer_id = managers.network:session():local_peer():id()
	local grenade = target_grenade_id
	local tweak = tweak_data.blackmarket.projectiles[grenade]
	local final_amount = managers.modifiers:modify_value("PlayerManager:GetGrenadeMaxAmount", target_grenade_amount or 1, {equipment = grenade})

	managers.player._global.synced_grenades[peer_id] = {
		grenade = grenade,
		amount = Application:digest_value(final_amount, true)
	}

	managers.hud:set_teammate_grenades(HUDManager.PLAYER_PANEL, {
		icon = tweak.icon,
		amount = final_amount
	})

	managers.player:update_grenades_amount_to_peers(grenade, final_amount, peer_id)

    for s, data in pairs(Global.blackmarket_manager.grenades) do
		data.equipped = s == target_grenade_id
	end

	MenuCallbackHandler:_update_outfit_information()

	if SystemInfo:distribution() == Idstring("STEAM") then
		managers.statistics:publish_equipped_to_steam()
	end
end

function LoadoutSwapper:openGearCategoryMenu()
    self:load()

    local menu_options = {}
    local selected_gear = _G.LS_SELECTED_GEAR
    local gear_data = self.data["grenades"]
    local title = "Loadout Swapper By AntonisK"
    local message = "Weapon Loadout Options"
    
    self:switch(selected_gear, {
        [4] = function() gear_data = self.data["grenades"] end,
        [5] = function() gear_data = self.data["armors"] end,
        [6] = function() gear_data = self.data["deployables"] end,
        ["default"] = function() self:scriptLog("[LoadoutSwapper]: Something Went Wrong...", Color.red) end
    })

    if not gear_data or not gear_data.available_slots or #gear_data.available_slots == 0 then
        table.insert(menu_options, {})
        table.insert(menu_options, {text = "No Gear Found", callback = back_to_gear_options})
        self:scriptLog("[LoadoutSwapper]: Something Went Wrong..." .. selected_gear, Color.red)
    else
        for i, gear in ipairs(gear_data.available_slots) do
            local LS = _G.LoadoutSwapper or {}
            local name = gear.name or gear.id -- fallback
            self:switch(selected_gear, {
                [4] = 
                    function()
                        table.insert(menu_options, {
                            text = name,
                            callback = function() LS:equipGrenade(gear.id, gear.max_amount) end
                        })
                    end,
                [5] = 
                    function()
                        table.insert(menu_options, {
                            text = name,
                            callback = function() managers.blackmarket:equip_armor(gear.id) end
                        })
                    end,
                [6] = 
                function()
                    table.insert(menu_options, {
                        text = name,
                        callback = function() LS:equipEquipment(gear.id) end
                    })
                end,
                ["default"] = function() self:scriptLog("[LoadoutSwapper]: Something Went Wrong...", Color.red) end
            })
        end
    end

    table.insert(menu_options, {})
    table.insert(menu_options, {text = "Back", callback = back_to_gear_options})
    table.insert(menu_options, {text = "Close", is_cancel_button = true})

    local myGearMenu = SimpleMenu:new(title, message, menu_options, 10)
    myGearMenu:show()
end

-- Entry point when called via LS_lua_run
function LoadoutSwapper:openGearMenu()
    local selected_gear = _G.LS_SELECTED_GEAR
    if not selected_gear then return self:scriptLog("[LoadoutSwapper]: Something Went Wrong...", Color.red) end

    if self:inLobby() then
        self:switch(selected_gear, {
            [4] = function() PlayerInventoryGui:open_throwable_menu() end,
            [5] = function() PlayerInventoryGui:open_armor_menu(1) end,
            [6] = function() PlayerInventoryGui:open_deployable_menu() end,
            ["default"] = function() self:scriptLog("[LoadoutSwapper]: Something Went Wrong...", Color.red) end
        })
    elseif self:inBriefing() then
        if not NewLoadoutTab then return end

        if not NewLoadoutTab._my_menu_component_data then NewLoadoutTab._my_menu_component_data = {} end

        NewLoadoutTab:open_node(selected_gear)
    elseif self:inGame() and self:getPlayer() then
        -- LoadoutSwapper:totalEquipmentAmount()
        LoadoutSwapper:openGearCategoryMenu()
    else
        self:scriptLog("[LoadoutSwapper]: Something Went Wrong...", Color.red)
    end
end

LoadoutSwapper:openGearMenu()