local LS_dofile = LS_dofile
--Hack lines
if (not orig__dofile) then
	orig__dofile = LS_dofile
end
--End of hacks

LS_dofile("lua/tools/ls_require.lua") --Loading improved ls_require function
__first_require_clbk =
function()
	LS_dofile("lua/setup/pre_init")
	--Write here code that needs to be executed on very first ls_require.
end