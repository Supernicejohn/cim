--[[
START ORDER CIM SCRIPTS

0 > this script, start.lua, inits all other scripts

1 > manager.lua, the pkg loader

2 > manager.lua called to load internal modules

3 > manager.lua, called to load external modules

4 > preload.lua, called to init modules that need
		startup outside of cim.

5 > cim.lua, the core cim file

6 > cim calls postload.lua

Untrusted (unstable) modules/scripts should be placed
	in postload.lua, or called to load from within cim
	itself, as these should be guarded better.

--]]

local args = {...}

-- 1, load manager
local manager = require("manager")

-- config manager
local i = 1
while true do
	if not args[i] then
		break
	end
	if args[i] == "-v" then
		manager._verbose = true
	end
	if args[i] == "-p" then
		manager._path = args[i + 1] or "/"
		i = i + 1
	end
	i = i + 1
end

-- 2 manager loads internal modules


