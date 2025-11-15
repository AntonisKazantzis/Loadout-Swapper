LS_io = {}
local io_open = io.open
local io_lines = io.lines
local io_popen = io.popen

LS_io.open = function(file, mode)
    file = "C:/Program Files (x86)/Steam/steamapps/common/PAYDAY 2/mods/Loadout Swapper/" .. file
    return io_open(file, mode)
end

LS_io.lines = function(file)
    file = "C:/Program Files (x86)/Steam/steamapps/common/PAYDAY 2/mods/Loadout Swapper/" .. file
    return io_lines(file)
end

LS_io.io_popen = function(command)
    command = command:gsub("lua/", "C:/Program Files (x86)/Steam/steamapps/common/PAYDAY 2/mods/Loadout Swapper/lua")
    return io_popen(command)
end

if not (orig__require) then
    local orig__require = LS_require
    local str_lower = string.lower
    local loadstring = loadstring
    local pcall = pcall
    local tostring = tostring
    local unpack = unpack
    local io_open = LS_io.open
    
    local __require_pre = {}
    local __require_after = {}
    local __require_override = {}
    
    local G = getfenv(0)
    G.orig__require = orig__require
    G.__require_pre = __require_pre
    G.__require_after = __require_after
    G.__require_override = __require_override
    
    local was__required = {}
    
    local first_require_clbk
    first_require_clbk = function()
        if rawget(_G, "__first_require_clbk") then
            local exec = __first_require_clbk
            __first_require_clbk = nil
            exec()
        end
        first_require_clbk = function()
        end
    end
    
    local function exec_before_clbks(path)
        local before_clbk = __require_pre[path]
        if before_clbk then
            before_clbk()
        end
    end
    
    local function exec_after_clbks(path)
        local after_clbk = __require_after[path]
        if after_clbk then
            after_clbk()
        end
    end
    
    local exts = {"", ".lua", ".luac"}
    
    function LS_require(in_path, safe, reload)
        local LS = _G.LoadoutSwapper or {}
        first_require_clbk()
        
        local path = str_lower(in_path)
        
        local __was_required = was__required[path]
        if (__was_required ~= nil and not reload) then
            return unpack(__was_required)
        end
        
        local before_clbk = __require_pre[path]
        if before_clbk then
            before_clbk()
        end
        
        local override_clbk = __require_override[path]
        if override_clbk then
            return override_clbk()
        end
        
        local f
        local final_path
        local i = 1
        repeat
            final_path = path .. exts[i]
            f = io_open(final_path, "rb")
            i = i + 1
        until f or i > 3
        if not f then
            if safe then
                return LS:customLog("Error: filename " .. in_path .. " wasn't found!\n")
            end
            local ret = orig__require(in_path)
            local after_clbk = __require_after[path]
            if after_clbk then
                after_clbk()
            end
            return ret
        end
        local exec, str_err = loadstring(f:read("*all"), final_path)
        f:close()
        if exec then
            if (safe) then
                local res = {pcall(exec)}
                if res[1] then
                    res = {unpack(res, 2)}
                    was__required[path] = res
                    local after_clbk = __require_after[path]
                    if after_clbk then
                        after_clbk()
                    end
                    return unpack(res)
                else
                    LS:customLog("Error: " .. res[2] .. "\n")
                end
            else
                local res = {exec()}
                was__required[path] = res
                local after_clbk = __require_after[path]
                if after_clbk then
                    after_clbk()
                end
                return unpack(res)
            end
        elseif str_err then
            LS:customLog("Error: " .. str_err .. "\n")
        end
    end
    function reset_requires()
        was__required = {}
    end
end