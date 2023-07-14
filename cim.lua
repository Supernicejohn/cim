manager = require("manager")
var = {}
t = {} 
b = {}
c = {}
w = {}
a = {}
file = {}
config = {}
std = {}
keymap = {} --key mappings/controls
--var = require("var") -- running vars
--t = require("text") --text
--b = require("command") --'bar'
--c = require("caret") --caret
--w = require("screen") --screen
--a = require("Vac.action") --actions
--file = require("file") --I/O
--config = require("config") --configurations
--std = require("std") --err/msgs
manager.addpkg("var")
manager.addpkg("text")
manager.addpkg("command")
manager.addpkg("caret")
manager.addpkg("screen")
manager.addpkg("Vac/action")
manager.addpkg("file")
manager.addpkg("std")
manager.addpkg("config")
-- GET
var = manager.getpkg("var")
t = manager.getpkg("text")
b = manager.getpkg("command")
c = manager.getpkg("caret")
w = manager.getpkg("screen")
a = manager.getpkg("Vac/action")
file = manager.getpkg("file")
std = manager.getpkg("std")
config = manager.getpkg("config")
--print("Debug over, dummy sleep of 5s")
--sleep(5)
var.args = {...}

t.init()
file.init()
c.init()
a.init()
b.init()
w.init()

while not var.exit do
	a.yield()
	w.render()
end
term.redirect(w.term)
term.setCursorPos(1,1)
term.clear()
