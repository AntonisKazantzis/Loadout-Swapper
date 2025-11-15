local LS = _G.LoadoutSwapper or {}
local io_open = LS_io.open
local loadstring = loadstring

function LS_lua_run(path, params)
    local file = io_open(path, "r")
    if file then
        local chunk = file:read("*all")
        file:close()

        -- Wrap chunk in a function taking a single argument
        local wrapped_chunk = "return function(info)\n" .. chunk .. "\nend"
        local exe, err = loadstring(wrapped_chunk)
        if exe then
            local fn = exe()
            fn(params)
        else
            _G.LoadoutSwapper:customLog("Error in '" .. path .. "': " .. tostring(err) .. "\n")
        end
    else
        _G.LoadoutSwapper:customLog("Couldn't open '" .. path .. "'.\n")
    end
end
