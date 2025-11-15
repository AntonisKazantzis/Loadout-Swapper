if not orig__dofile then
    orig__dofile = LS_dofile
    local LS_require = LS_require
    local LS_io = LS_io
    local io_open = LS_io.open
    local pcall = pcall or function(clbk, ...)
        return true, clbk(...)
    end

    local unpack = unpack
    local pairs = pairs
    local loadstring = loadstring
    local exts = {"", -- As is
    ".lua", -- Implicit
    ".luac" -- Implicit
    }

    function LS_dofile(name)
        local LS = _G.LoadoutSwapper or {}
        local err_msg = "nil argument was given"
        if (name) then
            local check
            for _, ext in pairs(exts) do
                check = io_open(name .. ext, "rb")
                if (check) then
                    break
                end
            end

            if (check) then
                local data = check:read("*all")
                check:close()
                if (data) then
                    local l, lerr = loadstring(data, name)
                    if (l) then
                        local res = {pcall(l)}
                        if (res[1]) then
                            return unpack(res, 2)
                        else
                            err_msg = res[2]
                        end
                    else
                        err_msg = lerr
                    end
                else
                    err_msg = "File " .. name .. " failed to load!"
                end
            else
                err_msg = "File " .. name .. " isn\"t found!"
            end
        end
        local customLog = customLog
		if (customLog) then
			customLog("LS_dofile()", err_msg)
		end
    end
end