_G.LoadoutSwapper = _G.LoadoutSwapper or {}
LoadoutSwapper.data = {}
LoadoutSwapper.equipemnt_data = {}

-- File path for storing loadout
LoadoutSwapper.path = ModPath
LoadoutSwapper.save_path = SavePath .. "StoredLoadout.json"

local LoadoutSwapper = _G.LoadoutSwapper or {}

-- Load the global loadout table from file
function LoadoutSwapper:load()
    local file = io.open(self.save_path, "r")
    if file then
        local content = file:read("*all")
        file:close()
        local decoded = json.decode(content)
        if decoded then
            self.data = decoded
        end
    end
end

-- Save the global loadout table to file
function LoadoutSwapper:save()
    local file = io.open(self.save_path, "w+")
    if file then
        file:write(json.encode(self.data))
        file:close()
    end
end

function LoadoutSwapper:logEquipmentSelections()
    local data = {}

    table.insert(data, { _equipment = managers.player._equipment})

    local file = io.open("C:/Program Files (x86)/Steam/steamapps/common/PAYDAY 2/mods/Loadout Swapper/logs/equipment_selections.json", "w+")
    if file then
        file:write(json.encode(data))
        file:close()
    else
        self:scriptLog("[LoadoutSwapper]: Something Went Wrong..." .. ModPath, Color.red)
    end
end

-- Store all loadout items: weapons, throwables, deployables, and armor
function LoadoutSwapper:storeAllLoadout()
    if not managers.blackmarket then return end

    -- Weapons
    local weapon_categories = {"primaries", "secondaries"}
    for _, category in ipairs(weapon_categories) do
        local slot = managers.blackmarket:equipped_weapon_slot(category)
        local equipped = (category == "primaries") and managers.blackmarket:equipped_primary() or managers.blackmarket:equipped_secondary()
        local crafted = managers.blackmarket:get_crafted_category(category) or {}

        local weapon_items = {}
        for i, weapon in pairs(crafted) do
            local tweak = tweak_data.weapon[weapon.weapon_id]
            local name = tweak and tweak.name_id and managers.localization:text(tweak.name_id) or weapon.weapon_id

            table.insert(weapon_items, {slot = i, name = name, id = weapon.weapon_id})

            self.data[category] = {
                available_slots = weapon_items,
                equipped_slot = weapon_items[slot]
            }
        end
    end

    -- Melee
    local melees_formatted = {}
    local melee_items = managers.blackmarket:get_sorted_melee_weapons(true, true) or {}
    for i, melee in ipairs(melee_items) do
        local all_melees = {}
        local equipped = managers.blackmarket:equipped_melee_weapon()
        local equipped_tweak = tweak_data.blackmarket.melee_weapons[equipped]
        local equipped_name = equipped_tweak and equipped_tweak.name_id and managers.localization:text(equipped_tweak.name_id) or equipped
        local tweak = tweak_data.blackmarket.melee_weapons[melee]
        local name = tweak and tweak.name_id and managers.localization:text(tweak.name_id) or equipped
        -- local slot = managers.blackmarket:equipped_melee_weapon_slot()

        table.insert(melees_formatted, {
            slot = i,
            id = melee,
            name = name
        })

        self.data["melees"] = {
            available_slots = melees_formatted,
            equipped_slot = {
                slot = i,
                id = equipped,
                name = equipped_name
            }
        }
    end

    -- Grenades
    local grenades_formatted = {}
    local grenade_items = managers.blackmarket:get_sorted_grenades(true) or {}
    for i, grenade in ipairs(grenade_items) do
        local all_grenades = {}
        local equipped = managers.blackmarket:equipped_projectile()
        local equipped_tweak = tweak_data.blackmarket.projectiles[equipped]
        local equipped_name = equipped_tweak and equipped_tweak.name_id and managers.localization:text(equipped_tweak.name_id) or grenade
        local tweak = tweak_data.blackmarket.projectiles[grenade[1]]
        local name = tweak and tweak.name_id and managers.localization:text(tweak.name_id) or grenade
        -- local slot = managers.blackmarket:equipped_grenade_slot()

        table.insert(grenades_formatted, {
            slot = i,
            id = grenade[1],
            name = name,
            max_amount = tweak.max_amount
        })

        self.data["grenades"] = {
            available_slots = grenades_formatted,
            equipped_slot = {
                slot = i,
                id = equipped,
                name = equipped_name,
                max_amount = equipped_tweak.max_amount
            }
        }
    end

    -- Armor
    local armors_formatted = {}
    local armor_items = managers.blackmarket:get_sorted_armors(true) or {}
    for i, armor in ipairs(armor_items) do
        local equipped = managers.blackmarket:equipped_armor()
        local equipped_tweak = tweak_data.blackmarket.armors[equipped]
        local equipped_name = equipped_tweak and equipped_tweak.name_id and managers.localization:text(equipped_tweak.name_id) or armor
        local tweak = tweak_data.blackmarket.armors[armor]
        local name = tweak and tweak.name_id and managers.localization:text(tweak.name_id) or armor
        -- local slot = managers.blackmarket:equipped_armor_slot()
    
        table.insert(armors_formatted, {
            slot = i,
            id = armor,
            name = name
        })

        self.data["armors"] = {
            available_slots = armors_formatted,
            equipped_slot = {
                slot = i,
                id = equipped,
                name = equipped_name
            }
        }
    end

    -- Deployables
    local deployables_formatted = {}
    local deployable_items = managers.blackmarket:get_sorted_deployables(true) or {}
    for i, deployable in ipairs(deployable_items) do
        local equipped_primary = managers.blackmarket:equipped_deployable(1)
        local equipped_secondary = managers.blackmarket:equipped_deployable(2)
        -- local slot_primary = managers.blackmarket:equipped_deployable_slot(equipped_primary)
        -- local slot_secondary = managers.blackmarket:equipped_deployable_slot(equipped_secondary)
        local tweak_primary = tweak_data.upgrades.definitions[equipped_primary]
        local tweak_secondary = tweak_data.upgrades.definitions[equipped_secondary]
        local equipped_name_primary = tweak_primary and tweak_primary.name_id and managers.localization:text(tweak_primary.name_id)
        local equipped_name_secondary = tweak_secondary and tweak_secondary.name_id and managers.localization:text(tweak_secondary.name_id)
        local tweak = tweak_data.upgrades.definitions[deployable[1]]
        local name = tweak and tweak.name_id and managers.localization:text(tweak.name_id)
        local deployable_data = tweak_data.equipments[deployable[1]]
        local primary_deployable_data = tweak_data.equipments[equipped_primary]
        local secondary_deployable_data = tweak_data.equipments[equipped_secondary]
        -- local max_amount = managers.player:equiptment_upgrade_value(deployable[1], "quantity")


        table.insert(deployables_formatted, {
            slot = i,
            id = deployable[1],
            name = name
        })

        self.data["deployables"] = {
            available_slots = deployables_formatted,
            equipped_slot = {
                equipped_primary = {
                    slot = i,
                    id = equipped_primary,
                    name = equipped_name_primary
                },
                equipped_secondary = {
                    slot = i,
                    id = equipped_secondary,
                    name = equipped_name_secondary,
                }
            }
        }
    end

    -- Save to JSON
    self:save()
end


Hooks:Add("MenuManagerInitialize", "MenuManagerInitialize_AmmoTypeChanger", function(menu_manager)
    local LS = _G.LoadoutSwapper or {}

    LS:storeAllLoadout()
    LS:load()
end)
