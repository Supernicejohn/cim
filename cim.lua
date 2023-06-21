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
var = require("var") -- running vars
t = require("text") --text
b = require("command") --'bar'
c = require("caret") --caret
w = require("screen") --screen
a = require("action") --actions
file = require("file") --I/O
config = require("config") --configurations
std = require("std") --err/msgs

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
