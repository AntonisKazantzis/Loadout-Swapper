_G.LS_SELECTED_AMMO = tonumber(info)

local selected_ammo = _G.LS_SELECTED_AMMO
local LS = _G.LoadoutSwapper or {}

if not LS:inGame() and not LS:getPlayer() then
    return LS:scriptLog("[LoadoutSwapper]: You must be in game.", Color.red)
elseif not selected_ammo then 
    return LS:scriptLog("[LoadoutSwapper]: Something Went Wrong...", Color.red)
end

local wep_excluded_ammo = {
    ["wpn_fps_bow_plainsrider"] = true,
    ["wpn_fps_bow_hunter"] = true,
    ["wpn_fps_bow_arblast"] = true,
    ["wpn_fps_bow_frankish"] = true,
    ["wpn_fps_bow_long"] = true,
    ["wpn_fps_bow_ecp"] = true,
    ["wpn_fps_bow_elastic"] = true
}

local orig_func_create_bonuses = WeaponFactoryTweakData.create_bonuses
function WeaponFactoryTweakData:create_bonuses(tweak_data, ...)
    orig_func_create_bonuses(self, tweak_data, ...)

    for _, data in pairs(tweak_data.upgrades.definitions) do
        local factory_id = data.factory_id
        if data.weapon_id and tweak_data.weapon[data.weapon_id] and factory_id and
            self[factory_id] and self[factory_id].uses_parts and
            not wep_excluded_ammo[factory_id] then
            table.insert(self[factory_id].uses_parts, "wpn_fps_upg_a_custom")       -- Buckshot
            table.insert(self[factory_id].uses_parts, "wpn_fps_upg_a_explosive")    -- HE
            table.insert(self[factory_id].uses_parts, "wpn_fps_upg_a_piercing")     -- AP
        end
    end
end

local ammo_class_map = {
    [1] = "InstantBulletBase",
    [2] = "InstantExplosiveBulletBase",
    [3] = "InstantBulletBase"
}

local orig_func_fire = RaycastWeaponBase.fire

function RaycastWeaponBase:fire(...)
    local bullet_class_str = ammo_class_map[selected_ammo] or "InstantBulletBase"
    self._bullet_class = CoreSerialize.string_to_classtable(bullet_class_str)

    return orig_func_fire(self, ...)
end
