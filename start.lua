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
_G.manager = require("manager")


-- 2 manager loads internal modules

--manager.getpkg("var")
--manager.getpkg("text")
--manager.getpkg("command")
--manager.getpkg("caret")
--manager.getpkg("screen")
--manager.getpkg("Vac/action")
--manager.getpkg("file")
--manager.getpkg("std")
--manager.getpkg("config")

manager.addpkg("var")
manager.addpkg("text")
manager.addpkg("command")
manager.addpkg("caret")
manager.addpkg("screen")
manager.addpkg("Vac/action")
manager.addpkg("file")
manager.addpkg("std")
manager.addpkg("config")
-- 3 manager loads external modules

-- 4 script starts preload

-- 5 start of cim/ECiMm

shell.run("cim.lua", table.unpack(args))

