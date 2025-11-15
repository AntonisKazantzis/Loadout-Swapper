_G.LoadoutSwapper = _G.LoadoutSwapper or {}
local LoadoutSwapper = _G.LoadoutSwapper or {}

local io_open = LS_io.open
local current_date = os.date("%Y-%m-%d")
local current_time = os.date("%Y-%m-%d %H:%M:%S")

function LoadoutSwapper:customLog(msg)
    local file = io_open("logs/" .. current_date .. "-log.txt", "a+")
    if file then
        file:write(current_time .. " [Loudout Swapper]: " .. msg .. "\n")
        file:close()
    end
end