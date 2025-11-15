--Primary scripts, being used by LoadoutSwapper
--Purpose: initate commonly used scripts and requires
--Main LoadoutSwapper configuration file

--Early init, so managers will be initiated succefully.
init()

local _G = _G

--Lobotomy init function, so it will not execute 2nd time
rawset( _G, "init", function() end )

local LS_require = _G.LS_require
local LS_dofile = _G.LS_dofile

LS_require("lua/setup/config")

--Fixes dumb behavior of _G
LS_require("lua/tools/gfix")