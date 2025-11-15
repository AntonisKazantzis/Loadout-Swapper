_G.LoadoutSwapper = _G.LoadoutSwapper or {}
local LoadoutSwapper = _G.LoadoutSwapper or {}

local pairs = pairs
local unpack = unpack
local loadstring = loadstring
local io = io
local io_open = LS_io.open
local io_popen = LS_io.io_popen
local io_close = io.stdout.close
local string = string
local alive = alive
local managers = managers
local game_state_machine = game_state_machine

function LoadoutSwapper:inLobby()
    if not game_state_machine then return false end
    local state = game_state_machine:current_state_name()
    return state:find("menu_main")
end

function LoadoutSwapper:inTitlescreen()
    if not game_state_machine then return false end
    local state = game_state_machine:current_state_name()
    return state:find("titlescreen")
end

function LoadoutSwapper:inBriefing()
    if not BaseNetworkHandler then return false end
    return BaseNetworkHandler._gamestate_filter.waiting_for_players[game_state_machine:last_queued_state_name()]
end

function LoadoutSwapper:inGame()
    if not BaseNetworkHandler then return false end
    return BaseNetworkHandler._gamestate_filter.any_ingame_playing[game_state_machine:last_queued_state_name()]
end

function LoadoutSwapper:ucfirst(str) return (str:gsub("^%l", string.upper)) end

function LoadoutSwapper:makeDoubleHudString(a, b)
	return string.format("%01d|%01d", a, b)
end

function LoadoutSwapper:addHudItem(amount, icon)
	if #amount > 1 then
		managers.hud:add_item_from_string({
			amount_str = self:makeDoubleHudString(amount[1], amount[2]),
			amount = amount,
			icon = icon
		})
	else
		managers.hud:add_item({
			amount = amount[1],
			icon = icon
		})
	end
end

function LoadoutSwapper:setHudItemAmount(index, amount)
	if #amount > 1 then
		managers.hud:set_item_amount_from_string(index, self:makeDoubleHudString(amount[1], amount[2]), amount)
	else
		managers.hud:set_item_amount(index, amount[1])
	end
end

function LoadoutSwapper:scriptLog(msg, color)
    managers.mission._fading_debug_output:script().log(msg, color)
end

function LoadoutSwapper:inChat()
	if managers and managers.hud and managers.hud._chat_focus == true then
		return true
	end
end

function LoadoutSwapper:getPlayer()
    if managers.player:player_unit() and alive(managers.player:player_unit()) then
        return managers.player:player_unit()
    end
    return
end

function LoadoutSwapper:inSteelsight()
    local player = managers.player:local_player()
    local in_steelsight = false
    if player and alive(player) then
        in_steelsight = player:movement() and player:movement():current_state() and player:movement():current_state():in_steelsight() or false
    end
    return in_steelsight
end

function LoadoutSwapper:inCustody()
	local player = managers.player:local_player()
	local in_custody = false
	if	managers and managers.trade	and	alive(player)	then
		in_custody = managers.trade:is_peer_in_custody(managers.network:session():local_peer():id())
	end
	return in_custody
end

function LoadoutSwapper:tablePrint(tt, done)
    done = done or {}
    if type(tt) == "table" then
        for key, value in pairs(tt) do
            if type(value) == "table" and not done[value] then
                done[value] = true
                self:customLog(string.format("<%s>	=>	table", tostring(key)));
                self:tablePrint(value, done)
            else
                self:customLog(string.format("[%s]	=>	%s", tostring(key), tostring(value)))
            end
        end
    else
        self:customLog(tt)
    end
end

function LoadoutSwapper:getSlot()
	local equipment = managers.player:selected_equipment()
	if equipment ~= nil then
		local slot = managers.player:equipment_slot(equipment.equipment)
		if slot then
			local amount = managers.player:get_equipment_amount(equipment.equipment, slot)
			if type(amount) == "number" and amount > 0 then
				return slot, amount
			end
		end
	end
	return false
end

function LoadoutSwapper:switch(value, cases)
    local case_func = cases[value]
    if case_func then
        return case_func()
    elseif cases["default"] then
        return cases["default"]()
    end
end
