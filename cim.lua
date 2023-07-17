
-- GET
local var = manager.getpkg("var")
local t = manager.getpkg("text")
local b = manager.getpkg("command")
local c = manager.getpkg("caret")
local w = manager.getpkg("screen")
local a = manager.getpkg("Vac/action")
local file = manager.getpkg("file")
local std = manager.getpkg("std")
local config = manager.getpkg("config")
local args = {...}
for k,v in pairs(args) do
	var.args[k] = v
end

manager.listpkgs()
--t.init()
--file.init()
--c.init()
--a.init()
--b.init()
--w.init()
file.start()
c.start()

while not var.exit do
	a.yield()
	w.render()
end
term.redirect(w.term)
term.setCursorPos(1,1)
term.clear()
