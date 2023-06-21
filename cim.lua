local args = {...}

local cim = {} -- running vars
local t = {} --text
local b = {} --'bar'
local c = {} --caret
local w = {} --screen
local a = {} --actions
local state = "normal" -- normal, insert, visual, command
local state_text = {normal = "Normal", text = "Insert", visual = "Visual"}
local file = {} --I/O
local keymap = {} --key mappings/controls
local config = {} --configurations
local std = {} --err/msgs

--### Default config ###
config.newline = "\n"
config.tabulate = "\t"
config.linewrap = false --TODO: testing this
config.blinking = true
config.text_color = colors.white
config.background_color = colors.black
config.escape_key = keys.leftCtrl

--### End Default config ###

std.err = function(err)
	b.message(err)
end

file.init = function()
	file.files = {}
	file.edited = {}
	file.active = 1
	if #args > 0 then
		file.files[1] = file.open(args[1], true)
		if not file.files[1] then
			file.files[1] = file.new(args[1], true)
		end
		file.edited[1] = false
	end
end
file.new = function(path, rel)
	if not path or #path==0 then
		path = "_new"
	end
	if rel then
		path = fs.combine(shell.dir(), path)
	end
	return path
end
file.open = function(path, rel)
	if not path or #path==0 then
		std.err("could not open <empty>")
		return
	end
	if (rel) then
		path = fs.combine(shell.dir(), path)
	end
	local file = fs.open(path, "r")
	if not file then
		std.err("could not open <"..path..">")
		return
	end
	t.text = {}
	while true do
		local line = file.readLine()
		if not line then
			break
		end
		t.text[#t.text+1] = line
	end
	file.close()
	return path --absolute path
end
file.save = function(path, rel)
	if not path or #path==0 then
		std.err("could not save to <empty>")
		return
	end
	if (rel) then
		path = fs.combine(path, shell.dir())
	end
	local file = fs.open(path, "w")
	if not file then
		std.err("could not save to <"..path..">")
		return
	end
	for i=1, #t.text do
		file.write(t.text[i]..config.newline)
	end
	file.close()
end

t.init = function()
	t.text = {}
	t.text[1] = ""
end
t.vis_line = function(n)
	if t.text and t.text[n] then
	   return t.text[n]
	else
	   return config.empty_line_fill
	end
end
t.write = function(str, caret)
	if not str or not caret then
	   return
	end
	file.edited[file.active] = true
	if not t.text[caret.y] or #t.text[caret.y]+1 < caret.x then
	   return
	end
	t.text[caret.y] = t.text[caret.y]:sub(1,caret.x-1)..str..
			t.text[caret.y]:sub(caret.x,#t.text[caret.y])
	caret.x = caret.x + #str
end
t.remove = function(caret1, caret2, mode)
	if caret1.y > caret2.y then
		return
	elseif caret1.y == caret2.y and caret1.x > caret2.x then
		return
	end
	-- straight-through mode
	-- TODO: test
	if mode == "straight" then
		local y = caret1.y
		local first = t.text[y]:sub(1, caret1.x)
		while y < caret2.y do
			if caret1.y < y and y < caret2.y then
				table.remove(t.text, y)
				caret2.y = caret2.y - 1
			end
			if y == caret2.y then
				t.text[y] = t.text[y]:sub(caret2.x, #t.text[y])
				t.text[y] = first..t.text[y]
			end
		end
	end
end
t.backspace = function()
	if c.caret.x == 1 and c.caret.y == 1 then
		return
	elseif c.caret.x == 1 then
		local len = #t.text[c.caret.y-1]
		t.text[c.caret.y-1] = t.text[c.caret.y-1]..t.text[c.caret.y]
		table.remove(t.text, c.caret.y)
		c.caret.y = c.caret.y - 1
		c.caret.x = len+1
	else
		t.text[c.caret.y] = t.text[c.caret.y]:sub(1, c.caret.x-2)..
				t.text[c.caret.y]:sub(c.caret.x, #t.text[c.caret.y])
		c.caret.x = c.caret.x - 1
	end
end
t.enter = function()
	local line = t.text[c.caret.y]:sub(c.caret.x, #t.text[c.caret.y])
	t.text[c.caret.y] = t.text[c.caret.y]:sub(1, c.caret.x-1)
	table.insert(t.text, c.caret.y+1, line)
	c.caret.x = 1
	c.caret.y = c.caret.y + 1
end
t.delete = function()
	--TODO
end

b.init = function()
	b.history = {[1] = ""}
	b.text = ""
end
b.message = function(str)
	b.text = str
end
b.run = function()
	--Interpret commands TODO
	local force = false
	local save = false
	local quit = false
	for i=1, #b.history[1] do
		local char = b.history[1]:sub(i,i)
		if char == "q" then
			quit = true
		elseif char == "w" then
			save = true
		elseif char == "!" then
			force = true
		end -- obviously not adequate for vim-like, but quick and easy
	end
	if save then
		if file.files[1] then
			file.save(file.files[1], false)
		end
	end
	if quit then
		--[[if file.changed[file.active] and not force then
			return
		end]]--
		cim.exit = true
	end
end


c.init = function()
	c.caret = {}
	c.caret.x = 1
	c.caret.y = 1
	c.current_blink = true
	c.start_blink()
	c.bgcol = colors.black
	c.fgcol = colors.white
end
c.start_blink = function()
	if c.blink_timer then
		os.stopTimer(c.blink_timer)
	end
	c.blink_timer = os.startTimer(0.4)
end
c.move = function(x,y)
	c.caret.x = c.caret.x + x
	c.caret.y = c.caret.y + y
end
c.set = function(x,y)
	c.caret.x = x
	c.caret.y = y
end
c.chk_move = function(x,y)
	if config.linewrap then
		return --TODO
	end
	if #t.text >= c.caret.y + y and c.caret.y + y > 0 then
		c.caret.y = c.caret.y + y
		if #t.text[c.caret.y]+1 < c.caret.x then
			c.caret.x = #t.text[c.caret.y]+1
		end
	end
	if #t.text[c.caret.y] + 1 >= c.caret.x + x and 0 < c.caret.x + x then
		c.caret.x = c.caret.x + x
	elseif c.caret.x + x > #t.text[c.caret.y] + 1 then
		c.caret.x = #t.text[c.caret.y] + 1
	else
		c.caret.x = 1
	end
end

w.init = function()
	w.term = term.current()
	w.dimensions = {}
	w.screen = {}
	w.dimensions.w, w.dimensions.h = w.term.getSize()
	w.screen.x = 1
	w.screen.y = 1
	w.screen.w = w.dimensions.w
	w.screen.h = w.dimensions.h - 1
	w.text = window.create(w.term, 1, 1,
			w.dimensions.w, w.dimensions.h-1)
	w.bar = window.create(w.term, 1, w.dimensions.h,
			w.dimensions.w, 1)
	w.msg_str = ""
	for i=1, w.screen.w do
		w.msg_str = w.msg_str.." "
	end
	
end
w.keep_focus = function(mode)
	if not mode then --default behavior
		while c.caret.x > (w.screen.x - 1 + w.screen.w) do
			w.screen.x = w.screen.x + 1;
		end
		while c.caret.x < (w.screen.x) do
			w.screen.x = w.screen.x - 1
		end
		while c.caret.y > (w.screen.y - 1 + w.screen.h) do
			w.screen.y = w.screen.y + 1
		end
		while c.caret.y < (w.screen.y) do
			w.screen.y = w.screen.y - 1
		end
	end
end
w.render = function()
	w.keep_focus()
	term.redirect(w.term)
	w.text.setVisible(true)
	w.bar.setVisible(true)
	w.draw_text()
	w.draw_bar()
	w.text.setVisible(false)
	w.bar.setVisible(false)
end
w.render_bar = function()
	w.bar.setVisible(true)
	w.draw_bar()
	term.redirect(w.term)
	w.bar.setVisible(false)
end
w.screen_line = function(n) --TODO: make scrolling work correctly
	local y = w.screen.y
	if config.linewrap then
		local index = w.screen.y
		local line = t.text[index] --get first visible row on screen
		local sub = ""
		for i=1, w.screen.h do
			if #line == 0 then
				index = index + 1
				line = t.text[index]
			end
			sub = line:sub(1, w.screen.w)
			if i == n then
				return sub
			end
			if #line > #sub then
				line = line:sub(w.screen.w+1, #line)
			end
		end
	else
		if t.text[w.screen.y + n - 1] then
			return t.text[w.screen.y + n - 1]:sub(w.screen.x, 
				w.screen.x - 1 + w.screen.w)
		else
			return "~"
		end
	end
end
w.draw_text = function()
	term.redirect(w.text)
	for i=1, w.screen.h do
		term.setCursorPos(1,i)
		term.clearLine()
		term.write(w.screen_line(i)) -- logical screen line
	end
	w.draw_caret()
end
w.draw_caret = function()
	term.redirect(w.text)
	term.setCursorPos(c.caret.x-w.screen.x+1, c.caret.y-w.screen.y+1)
	local bgc = term.getBackgroundColor()
	term.setBackgroundColor(c.bgcol)
	local char = w.screen_line(c.caret.y-w.screen.y+1)
		:sub(c.caret.x-w.screen.x+1, c.caret.x-w.screen.x+1)
	if c.current_blink then
		if not char or #char == 0 then
			char = "_"
		end
		term.write(char)
	else
		if not char or #char == 0 then
			term.write(" ")
		else
			term.write("_")
		end
	end
	term.setBackgroundColor(bgc)
end
w.draw_bar = function()
	term.redirect(w.bar)
	term.clearLine()
	term.setCursorPos(1,1)
	term.write(b.text)
end

a.init = function()
	state = "normal"
end
a.escape = function()
	state = "normal"
	b.message("Normal")
end
a.movement = function(event)
	if event[1] == "key" and state ~= "text" then
		if event[2] == keys.k then
			c.chk_move(0, -1)
		elseif event[2] == keys.j then
			c.chk_move(0, 1)
		elseif event[2] == keys.h then
			c.chk_move(-1, 0)
		elseif event[2] == keys.l then
			c.chk_move(1, 0)
		end
	end
	if event[1] == "key" then
		if event[2] == keys.up then
			c.chk_move(0, -1)
		elseif event[2] == keys.down then
			c.chk_move(0, 1)
		elseif event[2] == keys.left then
			c.chk_move(-1, 0)
		elseif event[2] == keys.right then
			c.chk_move(1, 0)
		elseif event[2] == keys.pageUp then
			for i=1, w.screen.h do
				c.chk_move(0, -1)
			end
		elseif event[2] == keys.pageDown then
			for i=1, w.screen.h do
				c.chk_move(0, 1)
			end
		elseif event[2] == keys.home then
			c.chk_move(-999999, 0)
		elseif event[2] == keys["end"] then
			c.chk_move(999999, 0)
		end
	end
end
a.textkeys = function(event)
	if event[1] == "key" then
		if event[2] == keys.enter then
			t.enter()
		elseif event[2] == keys.backspace then
			t.backspace()
		end
	end
end
a.control_keys = function(event)
	if event[1] == "key" then
		if event[2] == config.escape_key then
			a.escape()
			return true
		end
	end
	return false
end
a.normal = function(event)
	if event[1] == "key" then
		if a.control_keys(event) then
			return
		end
		a.movement(event)
	elseif event[1] == "char" then
		if event[2] == "i" then
			state = "text"
		elseif event[2] == ":" then
			state = "command"
		elseif event[2] == "v" then
			state = "visual"
		end
	end
end
a.text = function(event)
	if event[1] == "char" then
		t.write(event[2], c.caret)
	elseif event[1] == "key" then
		if a.control_keys(event) then
			return
		end
		a.movement(event)
		a.textkeys(event)
	end
end
a.visual = function(event)
	--TODO
	if event[1] == "key" then
		if a.control_keys(event) then
			return
		end
		a.movement(event)
	end
end
a.command = function(event)
	b.message(":"..b.history[1])
	if event[1] == "key" then
		if a.control_keys(event) then
			table.insert(b.history, 1, "")
			return
		end
		if event[2] == keys.enter then
			b.run()
			table.insert(b.history, 1, "")
			state = "normal"
			return
		elseif event[2] == keys.backspace then
			b.history[1] = b.history[1]:sub(1, #b.history[1]-1)
			return
		end
	elseif event[1] == "char" then
		b.history[1] = b.history[1]..event[2]
	end
end
a.yield = function()
	--w.render_bar()
	local e = {coroutine.yield()}
	if e[1] == "terminate" then
		b.message("Use ':q!' to exit")
	elseif e[1] == "timer" then
		if e[2] == c.blink_timer then
			c.current_blink = not c.current_blink
			c.blink_timer = nil
			c.start_blink()
		end
	elseif a[state] then
		a[state](e)
	end
	local stext = state_text[state] or ""
	if state ~= "command" then
		local caret_str = c.caret.x..":"..c.caret.y
		local str = stext..w.msg_str:sub(#stext+1, 
			w.screen.w - #caret_str - 3)..caret_str
		b.message(str)
	end
end

t.init()
file.init()
c.init()
a.init()
b.init()
w.init()
t.write(err)

while not cim.exit do
	a.yield()
	w.render()
end
term.redirect(w.term)
term.setCursorPos(1,1)
term.clear()
