--[[
	Init file for some helpfull core functions.
	LS_require it before init.lua being executed.
]]

local LS_require = LS_require
local rawget = rawget

if (not orig__require) then
	orig__require = LS_require
end

LS_require("lua/tools/ls_dofile")

--Setup for underground light hook

local __require_after = rawget(_G, "__require_after")
if (__require_after) then
	local LS_dofile = LS_dofile
	
	__require_after["lib/entry"] = 
	function()
		LS_dofile("lua/setup/init")
	end
end